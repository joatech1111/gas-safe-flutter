package com.joatech.gasmax.webapi.services;

import java.util.Map;

import com.joatech.gasmax.webapi.domains.SMSNoticesRepository;

/*
 * SMS 점검 안내문
 */
public class SMSNoticesService implements ISMSNoticesService {
	
	private SMSNoticesRepository repo;
	
	public SMSNoticesService(String dbHostname, int dbPortNumber, String dbName, String dbUsername, String dbPassword) {
		repo = new SMSNoticesRepository(dbHostname, dbPortNumber, dbName, dbUsername, dbPassword);
	}
	
	public void close() {
		repo.close();
	}

	@Override
	public Map<String, Object> getSMSNoticesByAreaCode(String areaCode) {
		return repo.findSmsNoticesSafeBy(areaCode);
	}
	
	@Override
	public Map<String, Object> getSMSNoticesByAreaCodeAndSmsDiv(String areaCode, String smsDiv) {
		return repo.findSmsNoticesSafeSmsDivBy(areaCode, smsDiv);
	}

}
