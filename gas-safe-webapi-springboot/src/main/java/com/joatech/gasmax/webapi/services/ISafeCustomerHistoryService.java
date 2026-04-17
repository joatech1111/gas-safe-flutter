package com.joatech.gasmax.webapi.services;

import java.util.List;
import java.util.Map;

/*
 * 안전점검 현황(거래처 점검 이력)
 */
public interface ISafeCustomerHistoryService {
	
	List<Map<String, Object>> getSafeCustomerHistoryByOrderBy(String areaCode, String cuCode, String shDate, String orderBy);

}
