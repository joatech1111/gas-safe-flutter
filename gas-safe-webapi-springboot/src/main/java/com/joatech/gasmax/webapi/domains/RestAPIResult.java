package com.joatech.gasmax.webapi.domains;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

public class RestAPIResult {
	private Long timestamp;
	private String result;
	private int resultCode;
	private Object resultData;
	
	public RestAPIResult(String result, int resultCode, Object resultData) {
		this.result = result;
		this.resultCode = resultCode;
		this.resultData = resultData;

		this.timestamp = System.currentTimeMillis();
	}
	
	public Long getTimestamp() {
		return this.timestamp;
	}
	
	public String getResult() {
		return this.result;
	}
	
	public int getResultCode() {
		return this.resultCode;
	}
	
	public Object getResultData() {
		return this.resultData;
	}

	public String toJsonString() {

		ObjectMapper mapper = new ObjectMapper();
		Map<String, Object> mapResult = new HashMap<String, Object>();
		mapResult.put("timestamp", timestamp);
		mapResult.put("result", result);
		mapResult.put("resultCode", resultCode);

		String jsonResult = "";
		ObjectMapper mapperResult = new ObjectMapper();
		JsonNode jsonNode;
		try {
			if (resultData != null) {
				jsonNode = mapperResult.readTree((String)resultData);
				if (jsonNode != null)
					mapResult.put("resultData", jsonNode);
			}
			jsonResult = mapper.writeValueAsString(mapResult);
		} catch (IOException e) {
			e.printStackTrace();
		}

		return jsonResult;
	}
}
