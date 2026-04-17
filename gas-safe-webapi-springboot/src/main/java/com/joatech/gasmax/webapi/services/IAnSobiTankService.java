package com.joatech.gasmax.webapi.services;

import java.util.List;
import java.util.Map;
import com.joatech.gasmax.webapi.domains.AnSobiTank;

/*
 * 저장탱크 안전점검표 Select View(탱크 점검 Select)
 */
public interface IAnSobiTankService {
	
	Map<String, Object> addNewAnSobiTank(AnSobiTank anSobiTank);
	Map<String, Object> updateAnSobiTank(AnSobiTank anSobiTank);
	Map<String, Object> deleteAnSobiTank(AnSobiTank anSobiTank);
	
	List<Map<String, Object>> getAnSobiTankServiceBy(String areaCode, String anzCucode, String anzSno);
	List<Map<String, Object>> getLastAnSobiTankServiceBy(String areaCode, String anzCucode);

}
