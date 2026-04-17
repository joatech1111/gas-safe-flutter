package com.joatech.gasmax.webapi.services;

import java.util.List;
import java.util.Map;
import com.joatech.gasmax.webapi.domains.AnSobiSafe;

/*
 * 사용시설점검 Select View
 */
public interface IAnSobiSafeService {
	
	Map<String, Object> addNewAnSobiSafe(AnSobiSafe anSobiSafe);
	Map<String, Object> updateAnSobiSafe(AnSobiSafe anSobiSafe);
	Map<String, Object> deleteAnSobiSafe(AnSobiSafe anSobiSafe);
	
	List<Map<String, Object>> getAnSobiSafeServiceBy(String areaCode, String anzCucode, String anzSno);
	List<Map<String, Object>> getLastAnSobiSafeBy(String areaCode, String anzCucode);

}
