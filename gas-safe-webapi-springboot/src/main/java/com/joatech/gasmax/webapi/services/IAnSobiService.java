package com.joatech.gasmax.webapi.services;

import java.util.List;
import java.util.Map;
import com.joatech.gasmax.webapi.domains.AnSobi;

/*
 * 소비설비 안전점검표 Select View(소비설비이력Select)
 */
public interface IAnSobiService {
	
	Map<String, Object> createAnSobi(AnSobi anSobi);
	Map<String, Object> updateAnSobi(AnSobi anSobi);
	Map<String, Object> deleteAnSobi(AnSobi anSobi);
	

	List<Map<String, Object>> getAnSobiServiceBy(String areaCode, String anzCuCode, String anzSno);
	List<Map<String, Object>> getAnSobiServiceBy3(String areaCode, String anzCuCode, String anzSno);
	List<Map<String, Object>> getLastAnSobiServiceBy(String areaCode, String anzCuCode);
	List<Map<String, Object>> getLastAnSobiServiceBy3(String areaCode, String anzCuCode);
}
