@php
    $content = $getState();
    $preview = $content ? \Illuminate\Support\Str::limit($content, 60) : '-';
    $full = $content ? \Illuminate\Support\Str::markdown($content, ['html_input' => 'strip']) : '';
@endphp

<div
    style="position:relative;cursor:default;"
    onmouseenter="this.querySelector('.md-pop').style.display='block'"
    onmouseleave="this.querySelector('.md-pop').style.display='none'"
>
    <span>{{ $preview }}</span>
    @if($full)
    <div class="md-pop" style="display:none;position:absolute;z-index:9999;left:0;top:1.5rem;width:24rem;max-height:20rem;overflow-y:auto;background:#fff;border:1px solid #e5e7eb;border-radius:.5rem;padding:1rem;box-shadow:0 10px 25px rgba(0,0,0,.15);">
        <div class="prose prose-sm">{!! $full !!}</div>
    </div>
    @endif
</div>
