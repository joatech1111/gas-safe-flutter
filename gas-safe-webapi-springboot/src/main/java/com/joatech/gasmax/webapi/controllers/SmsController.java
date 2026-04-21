package com.joatech.gasmax.webapi.controllers;

import java.util.HashMap;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.web.client.DefaultResponseErrorHandler;
import org.springframework.web.client.RestTemplate;

import com.joatech.gasmax.webapi.domains.RestAPIResult;

/*
 * SMS 발송 (외부 joabill.co.kr API 프록시)
 */
@RestController
@RequestMapping("/gas/api/sms")
public class SmsController {

	/*================================================================
	 * Private Members
	 ================================================================*/
	private final Logger logger = LoggerFactory.getLogger(getClass());

	private static final String SMS_ENDPOINT = "https://joabill.co.kr/custom";
	private static final String SEND_ID = "t123";
	private static final String SEND_NO = "15662399";
	private static final String DEFAULT_SUBJECT = "[조아테크]";

	private final RestTemplate restTemplate = buildRestTemplate();

	private static RestTemplate buildRestTemplate() {
		// HttpURLConnection이 streaming mode에서 401 받았을 때
		// HttpRetryException 던지는 문제 회피
		SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
		factory.setOutputStreaming(false);
		factory.setConnectTimeout(10000);
		factory.setReadTimeout(30000);

		RestTemplate rt = new RestTemplate(factory);
		// upstream 4xx/5xx 응답을 예외 대신 그대로 반환받도록 처리
		rt.setErrorHandler(new DefaultResponseErrorHandler() {
			@Override
			public boolean hasError(org.springframework.http.client.ClientHttpResponse response) {
				return false;
			}
		});
		return rt;
	}

	/*================================================================
	 * Public Rest API
	 ================================================================*/
	/*
	 * SMS 발송
	 *  - Request Body: { "recvNo": "01012345678", "text": "...", "subject": "..."(optional), "type": "SMS"(optional) }
	 */
	@PostMapping("/send")
	public RestAPIResult sendSms(@RequestBody Map<String, String> body) {
		String recvNo = body.get("recvNo");
		String text = body.get("text");
		String subject = body.getOrDefault("subject", DEFAULT_SUBJECT);
		String type = body.getOrDefault("type", "SMS");

		if (recvNo == null || recvNo.trim().isEmpty()) {
			return new RestAPIResult("fail", HttpStatus.BAD_REQUEST.value(),
					"{\"message\":\"recvNo is required\"}");
		}
		if (text == null || text.trim().isEmpty()) {
			return new RestAPIResult("fail", HttpStatus.BAD_REQUEST.value(),
					"{\"message\":\"text is required\"}");
		}

		try {
			HttpHeaders headers = new HttpHeaders();
			headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);

			MultiValueMap<String, String> formData = new LinkedMultiValueMap<>();
			formData.add("api_type", "SEND");
			formData.add("send_id", SEND_ID);
			formData.add("send_no", SEND_NO);
			formData.add("recv_no", recvNo);
			formData.add("text", text);
			formData.add("subject", subject);
			formData.add("type", type);

			HttpEntity<MultiValueMap<String, String>> request = new HttpEntity<>(formData, headers);
			ResponseEntity<String> response = restTemplate.postForEntity(SMS_ENDPOINT, request, String.class);
			int upstreamStatus = response.getStatusCodeValue();
			String upstreamBody = response.getBody();
			logger.info("SMS sent to {} - upstream status: {}, body: {}",
					maskPhone(recvNo), upstreamStatus, upstreamBody);

			Map<String, Object> data = new HashMap<>();
			data.put("upstreamStatus", upstreamStatus);
			data.put("upstreamBody", upstreamBody);

			String result = (upstreamStatus >= 200 && upstreamStatus < 300) ? "success" : "fail";
			return new RestAPIResult(result, upstreamStatus, toJson(data));
		} catch (Exception e) {
			logger.error("SMS send failed to {}: {}", maskPhone(recvNo), e.getMessage());
			return new RestAPIResult("fail", HttpStatus.INTERNAL_SERVER_ERROR.value(),
					"{\"message\":\"" + escapeJson(e.getMessage()) + "\"}");
		}
	}

	/*================================================================
	 * Helpers
	 ================================================================*/
	private String maskPhone(String phone) {
		if (phone == null || phone.length() < 4) return "****";
		return phone.substring(0, phone.length() - 4) + "****";
	}

	private String toJson(Map<String, Object> data) {
		try {
			return new com.fasterxml.jackson.databind.ObjectMapper().writeValueAsString(data);
		} catch (Exception e) {
			return "{}";
		}
	}

	private String escapeJson(String s) {
		if (s == null) return "";
		return s.replace("\\", "\\\\").replace("\"", "\\\"");
	}
}
