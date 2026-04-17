package com.joatech.gasmax.webapi.services;

import java.util.List;
import java.util.Map;

import com.joatech.gasmax.webapi.domains.SafeInsertList;

/*
 * 점검현황(FN점검현황 )
 */
public interface ISafeInsertListService {
	
	List<Map<String, Object>> getSafeInsertListServiceBy(SafeInsertList safeInsertList);
	List<Map<String, Object>> getGpsSafeInsertListeServiceBy(SafeInsertList safeInsertList);
	
	List<Map<String, Object>> getSafeInsertListServiceByOrderBy(SafeInsertList safeInsertList);
	List<Map<String, Object>> getGpsSafeInsertListeServiceByOrderBy(SafeInsertList safeInsertList);

}
