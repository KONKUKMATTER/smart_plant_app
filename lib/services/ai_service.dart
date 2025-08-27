// lib/services/ai_service.dart
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiService {
  AiService() {
    // .env 파일에서 불러온 API 키로 OpenAI 초기화
    OpenAI.apiKey = dotenv.env['OPENAI_API_KEY']!;
  }

  Future<String> getPlantInfo(String plantName) async {
    // AI에게 역할을 부여하는 시스템 메시지 (더 좋은 답변을 유도)
    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          "당신은 식물학자이자 정원사입니다. 사용자가 식물 이름을 물어보면, 그 식물의 핵심 특징과 관리 방법을 초보자도 이해하기 쉽게 설명해주세요. 답변은 한국어로, 마크다운 형식을 사용하여 제목과 목록을 보기 좋게 꾸며주세요.",
        ),
      ],
      role: OpenAIChatMessageRole.system,
    );

    // 사용자 질문 메시지
    final userMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          plantName,
        ),
      ],
      role: OpenAIChatMessageRole.user,
    );

    try {
      // OpenAI 채팅 API 호출
      final chatCompletion = await OpenAI.instance.chat.create(
        model: "gpt-4o-mini", // 최신이고 저렴한 모델
        messages: [systemMessage, userMessage],
        maxTokens: 300, // 답변 최대 길이
        temperature: 0.7, // 답변의 창의성 조절
      );

      // API 응답에서 텍스트만 추출하여 반환
      return chatCompletion.choices.first.message.content?.first.text ?? "정보를 불러올 수 없습니다.";
    } catch (e) {
      print("OpenAI API 오류: $e");
      return "AI 정보를 불러오는 중 오류가 발생했습니다. API 키와 인터넷 연결을 확인해주세요.";
    }
  }
}