package com.joatech.gasmax.webapi.controllers;

import java.net.URI;
import java.util.HashMap;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

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

	private final RestTemplate restTemplate = new RestTemplate();

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

		URI uri = UriComponentsBuilder.fromHttpUrl(SMS_ENDPOINT)
				.queryParam("api_type", "SEND")
				.queryParam("send_id", SEND_ID)
				.queryParam("send_no", SEND_NO)
				.queryParam("recv_no", recvNo)
				.queryParam("text", text)
				.queryParam("subject", subject)
				.queryParam("type", type)
				.build()
				.encode()
				.toUri();

		try {
			ResponseEntity<String> response = restTemplate.postForEntity(uri, null, String.class);
			logger.info("SMS sent to {} - status: {}", maskPhone(recvNo), response.getStatusCodeValue());

			Map<String, Object> data = new HashMap<>();
			data.put("upstreamStatus", response.getStatusCodeValue());
			data.put("upstreamBody", response.getBody());

			return new RestAPIResult("success", HttpStatus.OK.value(), toJson(data));
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
