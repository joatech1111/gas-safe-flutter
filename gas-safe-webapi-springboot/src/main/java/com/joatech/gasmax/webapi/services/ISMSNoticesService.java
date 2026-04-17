package com.joatech.gasmax.webapi.services;

import java.util.Map;

/*
 * SMS 점검 안내문
 */
public interface ISMSNoticesService {
	
	Map<String, Object> getSMSNoticesByAreaCode(String areaCode);
	Map<String, Object> getSMSNoticesByAreaCodeAndSmsDiv(String areaCode, String smsDiv);

}
