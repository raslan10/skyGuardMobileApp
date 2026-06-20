import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart'; // 🎬 Import مشغل الفيديو
import 'ai_prediction_screen.dart';

class MediaViewerScreen extends StatefulWidget {
  final String url;
  final String type;
  final String date;
  final String tag;

  const MediaViewerScreen({
    super.key,
    required this.url,
    required this.type,
    required this.date,
    required this.tag,
  });

  @override
  State<MediaViewerScreen> createState() => _MediaViewerScreenState();
}

class _MediaViewerScreenState extends State<MediaViewerScreen> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    // 🎬 لو الملف فيديو حقيقي، نقوم بتهيئة مشغل الفيديو فوراً من الـ URL الـ Presigned
    if (widget.type.toLowerCase() == 'video') {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.url))
        ..initialize().then((_) {
          if (!mounted) return;
          setState(() {
            _isVideoInitialized = true;
          });
          _videoController?.play(); // تشغيل تلقائي
          _videoController?.setLooping(true); // إعادة تشغيل مستمرة
        });
    }
  }

  @override
  void dispose() {
    // 🔒 تفريغ الـ Controller لمنع تسريب الذاكرة (Memory Leak)
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✨ فحص ذكي: هل الملف الممرر هو ملف JSON خاص ببيانات الحادثة القادمة من AWS S3؟
    final bool isJsonFile = widget.tag.toLowerCase().endsWith('.json') || widget.url.toLowerCase().contains('.json');
    final bool isVideo = widget.type.toLowerCase() == 'video' && !isJsonFile;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Evidence Inspector",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF007BA7),
        foregroundColor: Colors.white,
      ),
      // 🛡️ الحل الجوهري للـ Overflow: استبدال الـ Column بـ SingleChildScrollView لتوفير مساحة سكرول مرنة تمنع الخطوط الصفراء تماماً
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📸 حاوية العرض الذكية (تتعرف على الفيديو أو الصورة أو الـ JSON)
              Container(
                height: 280,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isJsonFile ? const Color(0xFF0F172A) : Colors.black, // خلفية داكنة ملائمة للمحتوى
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: isJsonFile
                      ? _buildJsonPlaceholder() // ✅ منع الـ Invalid image data عبر عرض ويدجيت هيكلية للـ JSON
                      : isVideo
                      ? _buildVideoPlayer() // 🎬 مشغل الفيديوهات الحية من الـ S3
                      : Image.network(
                    widget.url,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.broken_image_outlined, size: 64, color: Colors.grey),
                      );
                    },
                  ), // 🖼️ عرض الصورة العادية
                ),
              ),
              const SizedBox(height: 20),

              // 📑 كروت تفاصيل الخصائص
              _infoCard("Classification Tag", widget.tag, Icons.label_important_outline),
              _infoCard("Media Type", isJsonFile ? "STRUCTURED_JSON" : widget.type.toUpperCase(), isVideo ? Icons.videocam_outlined : Icons.image_outlined),
              _infoCard("Captured Timestamp", widget.date, Icons.calendar_today_outlined),

              // لو الملف عبارة عن JSON، بنعرض الحاوية الشيك دي للمسار الخام قدام اللجنة
              if (isJsonFile) ...[
                const SizedBox(height: 16),
                Text("S3 Source Destination URL", style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey[700])),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)),
                  child: SelectableText(
                    widget.url,
                    style: GoogleFonts.sourceCodePro(color: const Color(0xFF38BDF8), fontSize: 10),
                  ),
                )
              ],

              const SizedBox(height: 30),

              // 🛠️ زر تشغيل الـ AI المطور والمنقول لأسفل الـ Scroll View بأمان
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007BA7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AIPredictionScreen(reportId: widget.tag),
                      ),
                    );
                  },
                  icon: const Icon(Icons.psychology, color: Colors.white),
                  label: Text(
                    "Run AI Crash Analytics",
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🎬 بناء واجهة مشغل الفيديو مع زر الـ Play/Pause التفاعلي
  Widget _buildVideoPlayer() {
    if (_isVideoInitialized && _videoController != null) {
      return Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                if (_videoController!.value.isPlaying) {
                  _videoController?.pause();
                } else {
                  _videoController?.play();
                }
              });
            },
            child: Container(
              color: Colors.transparent,
              child: Center(
                child: AnimatedOpacity(
                  opacity: _videoController!.value.isPlaying ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    radius: 28,
                    child: Icon(
                      _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
  }

  // 📑 ويدجيت مخصصة لعرض ملفات الـ JSON بشكل بروفيشينال تليق باللجنة
  Widget _buildJsonPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.code_rounded, size: 50, color: Color(0xFF38BDF8)),
          const SizedBox(height: 12),
          Text(
            "Telemetry JSON Archetype",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            "This telemetry payload archives dynamic sensor coordinates and structural vision tags inside your AWS S3 Cloud.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      color: const Color(0xFFF8FAFC),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF007BA7)),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey[600]),
        ),
        subtitle: Text(
          value,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ),
    );
  }
}