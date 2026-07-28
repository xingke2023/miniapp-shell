import { useState } from "react";
import { useNavigate } from "react-router";
import { ChevronLeft, Search, User, Phone, MapPin, Briefcase } from "lucide-react";

interface Resume {
  id: number;
  name: string;
  phone: string;
  position: string;
  experience: string;
  location: string;
  date: string;
}

export function ResumeLibrary() {
  const navigate = useNavigate();
  const [searchTerm, setSearchTerm] = useState("");

  const resumes: Resume[] = [
    {
      id: 1,
      name: "陈小明",
      phone: "138****1234",
      position: "店员",
      experience: "2年生鲜零售经验",
      location: "香港湾仔",
      date: "2026-03-30",
    },
    {
      id: 2,
      name: "王丽华",
      phone: "139****5678",
      position: "店长",
      experience: "5年连锁门店管理经验",
      location: "香港中环",
      date: "2026-03-28",
    },
    {
      id: 3,
      name: "李大海",
      phone: "137****9012",
      position: "店员",
      experience: "1年零售经验",
      location: "香港铜锣湾",
      date: "2026-03-25",
    },
  ];

  const filteredResumes = resumes.filter(
    (resume) =>
      resume.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      resume.position.toLowerCase().includes(searchTerm.toLowerCase()) ||
      resume.location.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="min-h-screen bg-gradient-to-b from-primary/5 to-white pb-20">
      <div className="bg-white border-b border-border px-4 py-3 flex items-center gap-3">
        <button onClick={() => navigate("/profile")} className="text-primary">
          <ChevronLeft className="w-6 h-6" />
        </button>
        <h1 className="text-lg">简历库</h1>
      </div>

      {/* 搜索栏 */}
      <div className="bg-white border-b border-border px-6 py-4">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-muted-foreground" />
          <input
            type="text"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            placeholder="搜索姓名、职位、地点..."
            className="w-full pl-10 pr-4 py-2.5 rounded-lg bg-input-background border border-border focus:outline-none focus:ring-2 focus:ring-primary/20"
          />
        </div>
      </div>

      {/* 统计信息 */}
      <div className="px-6 py-4">
        <div className="flex items-center justify-between text-sm">
          <span className="text-muted-foreground">
            共找到 {filteredResumes.length} 份简历
          </span>
          <button className="text-primary">按日期排序</button>
        </div>
      </div>

      {/* 简历列表 */}
      <div className="px-6 pb-6">
        <div className="space-y-3">
          {filteredResumes.length === 0 ? (
            <div className="bg-white rounded-xl p-8 text-center">
              <Search className="w-12 h-12 text-muted-foreground mx-auto mb-2" />
              <p className="text-muted-foreground">未找到相关简历</p>
            </div>
          ) : (
            filteredResumes.map((resume) => (
              <div
                key={resume.id}
                className="bg-white rounded-xl p-5 border border-border hover:shadow-md transition-shadow"
              >
                <div className="flex items-start justify-between mb-3">
                  <div className="flex items-center gap-3">
                    <div className="w-12 h-12 rounded-full bg-gradient-to-br from-primary/20 to-accent/20 flex items-center justify-center">
                      <User className="w-6 h-6 text-primary" />
                    </div>
                    <div>
                      <h3 className="text-base mb-0.5">{resume.name}</h3>
                      <p className="text-xs text-muted-foreground">
                        应聘 {resume.position}
                      </p>
                    </div>
                  </div>
                  <span className="text-xs text-muted-foreground">
                    {resume.date}
                  </span>
                </div>

                <div className="space-y-2 text-sm">
                  <div className="flex items-center gap-2 text-muted-foreground">
                    <Phone className="w-4 h-4" />
                    <span>{resume.phone}</span>
                  </div>
                  <div className="flex items-center gap-2 text-muted-foreground">
                    <MapPin className="w-4 h-4" />
                    <span>{resume.location}</span>
                  </div>
                  <div className="flex items-center gap-2 text-muted-foreground">
                    <Briefcase className="w-4 h-4" />
                    <span>{resume.experience}</span>
                  </div>
                </div>

                <div className="flex gap-2 mt-4">
                  <button className="flex-1 py-2 rounded-lg border border-border text-sm hover:bg-muted/50 transition-colors">
                    查看详情
                  </button>
                  <button className="flex-1 py-2 rounded-lg bg-primary text-primary-foreground text-sm hover:opacity-90 transition-opacity">
                    联系Ta
                  </button>
                </div>
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
}
