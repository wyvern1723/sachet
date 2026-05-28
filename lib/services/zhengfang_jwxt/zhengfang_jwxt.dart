import 'class_schedule/class_schedule_service.dart';
import 'cultivation/cultivation_service.dart';
import 'exam_time/exam_time_service.dart';
import 'free_classroom/free_classroom_service.dart';
import 'gpa/gpa_service.dart';
import 'grade/grade_service.dart';
import 'reserve_textbook/reserve_textbook_service.dart';
import 'score_pdf/score_pdf_service.dart';

class ZhengFangJwxt {
  ZhengFangJwxt._();

  static const classSchedule = ClassScheduleService();
  static const grade = GradeService();
  static const freeClassroom = FreeClassroomService();
  static const cultivation = CultivationService();
  static const examTime = ExamTimeService();
  static const gpa = GPAService();
  static const reserveTextbook = ReserveTextbookService();
  static const scorePdf = ScorePdfService();
}
