package com.joatech.gasmax.webapi.services;

import java.util.List;
import java.util.Map;
import com.joatech.gasmax.webapi.domains.SafeCustomerHistoryRepository;

/*
 * 안전점검 현황(거래처 점검 이력)
 */
public class SafeCustomerHistoryService implements ISafeCustomerHistoryService {
	
	private SafeCustomerHistoryRepository repo;
	
	public SafeCustomerHistoryService(String dbHostname, int dbPortNumber, String dbName, String dbUsername, String dbPassword) {
		repo = new SafeCustomerHistoryRepository(dbHostname, dbPortNumber, dbName, dbUsername, dbPassword);
	}
	
	public void close() {
		repo.close();
	}

	@Override
	public List<Map<String, Object>> getSafeCustomerHistoryByOrderBy(String areaCode, String cuCode, String shDate, String orderBy) {

		return repo.findSafeCustomerHistoryByOrderBy(areaCode, cuCode, shDate, orderBy);
	}

}
