package com.joatech.gasmax.webapi.services;

import java.util.List;
import java.util.Map;

import com.joatech.gasmax.webapi.domains.SafetyCustomer;

/*
 * 점검 거래처 검색(FN_점검 검색어 검색)
 */
public interface ISearchSafeCustomerService {
	
	List<Map<String, Object>> getAllSearchSafeCustomerBy(SafetyCustomer safetyCustomer);
	List<Map<String, Object>> getAllSearchSafeCustomerByOrderBy(SafetyCustomer safetyCustomer);
	
	List<Map<String, Object>> getGpsAllSearchSafeCustomerBy(SafetyCustomer safetyCustomer);
	List<Map<String, Object>> getGpsAllSearchSafeCustomerByOrderBy(SafetyCustomer safetyCustomer);

}
