<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class MigrateMysqlData extends Command
{
    protected $signature = 'db:migrate-from-mysql
        {--database=laravel_app : 源 MySQL 数据库名}
        {--chunk=500 : 每批拷贝行数}';

    protected $description = '把旧 MySQL 库的业务数据按表拷贝到当前 PostgreSQL 库（仅复制两边都存在的表与列，处理布尔/JSON/非法日期）';

    /** 框架瞬态表，不迁移 */
    private array $skip = [
        'migrations', 'sessions', 'cache', 'cache_locks',
        'jobs', 'job_batches', 'failed_jobs', 'password_reset_tokens',
    ];

    public function handle(): int
    {
        config(['database.connections.mysql_src' => [
            'driver' => 'mysql',
            'host' => '127.0.0.1',
            'port' => 3306,
            'database' => $this->option('database'),
            'username' => 'laravel',
            'password' => 'laravel_password',
            'charset' => 'utf8mb4',
            'collation' => 'utf8mb4_unicode_ci',
        ]]);

        $src = DB::connection('mysql_src');
        $dst = DB::connection('pgsql');
        $chunk = (int) $this->option('chunk');

        // 源库所有基础表（去掉瞬态表、且目标 pgsql 也存在的）
        $srcTables = collect($src->select('SHOW TABLES'))
            ->map(fn ($r) => array_values((array) $r)[0])
            ->reject(fn ($t) => in_array($t, $this->skip, true))
            ->filter(fn ($t) => Schema::connection('pgsql')->hasTable($t))
            ->values();

        $this->info('将迁移 '.$srcTables->count().' 张表（仅两边都存在的表）');

        // 绕过外键校验（需要 superuser；调用方已临时授予）
        $dst->statement("SET session_replication_role = 'replica'");

        // 先全部清空目标表（CASCADE + RESTART IDENTITY），再逐表灌数据，避免 FK/顺序问题
        foreach ($srcTables as $t) {
            $dst->statement('TRUNCATE TABLE "'.$t.'" RESTART IDENTITY CASCADE');
        }

        $totalRows = 0;
        foreach ($srcTables as $t) {
            $rows = $this->copyTable($src, $dst, $t, $chunk);
            $totalRows += $rows;
            $this->line(sprintf('  %-32s %6d 行', $t, $rows));
        }

        // 重置自增序列到 max(id)
        foreach ($srcTables as $t) {
            if (Schema::connection('pgsql')->hasColumn($t, 'id')) {
                $dst->statement(
                    'SELECT setval(pg_get_serial_sequence(?, \'id\'), GREATEST((SELECT COALESCE(MAX(id),0) FROM "'.$t.'"), 1))',
                    [$t]
                );
            }
        }

        $dst->statement("SET session_replication_role = 'origin'");

        $this->info("完成：共迁移 {$totalRows} 行，{$srcTables->count()} 张表。");

        return self::SUCCESS;
    }

    private function copyTable(\Illuminate\Database\Connection $src, \Illuminate\Database\Connection $dst, string $table, int $chunk): int
    {
        // 目标列类型（pgsql）
        $colTypes = collect($dst->select(
            'SELECT column_name, data_type FROM information_schema.columns WHERE table_schema = ? AND table_name = ?',
            ['public', $table]
        ))->mapWithKeys(fn ($c) => [$c->column_name => $c->data_type]);

        $srcCols = $src->getSchemaBuilder()->getColumnListing($table);
        $common = array_values(array_intersect($srcCols, $colTypes->keys()->all()));
        if (empty($common)) {
            return 0;
        }

        $hasId = in_array('id', $common, true);
        $query = $src->table($table);
        if ($hasId) {
            $query->orderBy('id');
        } else {
            // 无主键的表（如 role_permissions 透视表）：按全部列排序保证分块确定性
            foreach ($common as $c) {
                $query->orderBy($c);
            }
        }

        $count = 0;
        $query->select($common)->chunk($chunk, function ($rows) use ($dst, $table, $common, $colTypes, &$count): void {
            $batch = [];
            foreach ($rows as $row) {
                $r = (array) $row;
                $clean = [];
                foreach ($common as $col) {
                    $clean[$col] = $this->cast($r[$col] ?? null, $colTypes[$col] ?? 'text');
                }
                $batch[] = $clean;
            }
            if ($batch) {
                $dst->table($table)->insert($batch);
                $count += count($batch);
            }
        });

        return $count;
    }

    /**
     * 按目标 pgsql 列类型转换 MySQL 取出的值。
     */
    private function cast(mixed $value, string $pgType): mixed
    {
        if ($value === null) {
            return null;
        }

        return match ($pgType) {
            'boolean' => (bool) $value,
            // 非法日期 '0000-00-00' 系列 → null
            'timestamp without time zone', 'timestamp with time zone', 'date' => str_starts_with((string) $value, '0000-00-00') ? null : $value,
            default => $value,
        };
    }
}
