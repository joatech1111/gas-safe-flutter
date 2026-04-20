package com.joatech.gasmax.webapi.services;

import java.util.List;
import java.util.Map;

import com.joatech.gasmax.webapi.domains.AnSobi;
import com.joatech.gasmax.webapi.domains.AnSobiRepository;

/*
 * 소비설비 안전점검표 Select View(소비설비이력Select)
 */
public class AnSobiService implements IAnSobiService {
	
	private AnSobiRepository repo;
	
	public AnSobiService(String dbHostname, int dbPortNumber, String dbName, String dbUsername, String dbPassword) {
		repo = new AnSobiRepository(dbHostname, dbPortNumber, dbName, dbUsername, dbPassword);
	}
	
	public void close() {
		repo.close();
	}

	/*
	 * 소비설비등록(SP_소비설비등록)
	 */
	@Override
	public Map<String, Object> createAnSobi(AnSobi anSobi) {
		
		anSobi.setSaveDiv("I");
		return executeAnSobi(anSobi);
	}

	// Update
	@Override
	public Map<String, Object> updateAnSobi(AnSobi anSobi) {
		
		anSobi.setSaveDiv("U");
		return executeAnSobi(anSobi);
	}
	
	// Delete
	@Override
	public Map<String, Object> deleteAnSobi(AnSobi anSobi) {
		
		anSobi.setSaveDiv("D");
		return executeAnSobi(anSobi);
	}

	// Create
	public Map<String, Object> createAnSobiNew(AnSobi anSobi) {
		
		anSobi.setSaveDiv("I");
		return executeAnSobiNew(anSobi);
	}
	
	// Update
	public Map<String, Object> updateAnSobiNew(AnSobi anSobi) {
		
		anSobi.setSaveDiv("U");
		return executeAnSobiNew(anSobi);
	}
	
	// Delete
	public Map<String, Object> deleteAnSobiNew(AnSobi anSobi) {
		
		anSobi.setSaveDiv("D");
		return executeAnSobiNew(anSobi);
	}


	// Create
	public Map<String, Object> createAnSobiNewAdd(AnSobi anSobi) {

		anSobi.setSaveDiv("I");
		return executeAnSobiNewAdd(anSobi);
	}

	// Update
	public Map<String, Object> updateAnSobiNewAdd(AnSobi anSobi) {

		anSobi.setSaveDiv("U");
		return executeAnSobiNewAdd(anSobi);
	}

	// Delete
	public Map<String, Object> deleteAnSobiNewAdd(AnSobi anSobi) {

		anSobi.setSaveDiv("D");
		return executeAnSobiNewAdd(anSobi);
	}

	/*
	 * 소비설비 안전점검표 - 점검 이력
	 */
	@Override
	public List<Map<String, Object>> getAnSobiServiceBy(String areaCode, String anzCuCode, String anzSno) {

		return repo.findAllAnSobiBy(areaCode, anzCuCode, anzSno);
	}

	/*
	 * 소비설비 안전점검표 - 점검 이력
	 */
	@Override
	public List<Map<String, Object>> getAnSobiServiceBy3(String areaCode, String anzCuCode, String anzSno) {

		return repo.findAll3AnSobiBy(areaCode, anzCuCode, anzSno);
	}

	/*
	 * 소비설비 안전점검표 - 신규 등록시 최종점검등록정보
	 */
	@Override
	public List<Map<String, Object>> getLastAnSobiServiceBy(String areaCode, String anzCuCode) {

		return repo.findLastAnSobiBy(areaCode, anzCuCode);
	}

	/*
	 * 소비설비 안전점검표 - 신규 등록시 최종점검등록정보
	 */
	@Override
	public List<Map<String, Object>> getLastAnSobiServiceBy3(String areaCode, String anzCuCode) {

		return repo.findLast3AnSobiBy(areaCode, anzCuCode);
	}

	private Map<String, Object> executeAnSobi(AnSobi anSobi) {
		return repo.executeSaveAnSobi(
				anSobi.getSaveDiv(),
				anSobi.getAreaCode(),
				anSobi.getAnzCuCode(),
				anSobi.getAnzSno(),
				anSobi.getAnzDate(),
				anSobi.getAnzSwCode(),
				anSobi.getAnzSwName(),
				anSobi.getAnzCustName(),
				anSobi.getAnzTel(),
				anSobi.getZipCode(),
				anSobi.getCuAddr1(),
				anSobi.getCuAddr2(),
				anSobi.getAnzA01(),
				anSobi.getAnzA02(),
				anSobi.getAnzA03(),
				anSobi.getAnzA04(),
				anSobi.getAnzA05(),
				anSobi.getAnzB01(),
				anSobi.getAnzB02(),
				anSobi.getAnzB03(),
				anSobi.getAnzB04(),
				anSobi.getAnzB05(),
				anSobi.getAnzC01(),
				anSobi.getAnzC02(),
				anSobi.getAnzC03(),
				anSobi.getAnzC04(),
				anSobi.getAnzC05(),
				anSobi.getAnzC06(),
				anSobi.getAnzC07(),
				anSobi.getAnzC08(),
				anSobi.getAnzGita01(),
				anSobi.getAnzD01(),
				anSobi.getAnzD02(),
				anSobi.getAnzD03(),
				anSobi.getAnzD04(),
				anSobi.getAnzD05(),
				anSobi.getAnzE01(),
				anSobi.getAnzE02(),
				anSobi.getAnzE03(),
				anSobi.getAnzE04(),
				anSobi.getAnzF01(),
				anSobi.getAnzF02(),
				anSobi.getAnzF03(),
				anSobi.getAnzF04(),
				anSobi.getAnzG01(),
				anSobi.getAnzG02(),
				anSobi.getAnzG03(),
				anSobi.getAnzG04(),
				anSobi.getAnzG05(),
				anSobi.getAnzG06(),
				anSobi.getAnzG07(),
				anSobi.getAnzG08(),
				anSobi.getAnzGita02(),
				anSobi.getAnzGa(),
				anSobi.getAnzNa(),
				anSobi.getAnzDa(),
				anSobi.getAnzRa(),
				anSobi.getAnzMa(),
				anSobi.getAnzBa(),
				anSobi.getAnzSa(),
				anSobi.getAnzAa(),
				anSobi.getAnzJa(),
				anSobi.getAnzChaIn(),
				anSobi.getAnzCha(),
				anSobi.getAnzCar(),
				anSobi.getAnzGae01(),
				anSobi.getAnzGae02(),
				anSobi.getAnzGae03(),
				anSobi.getAnzGae04(),
				anSobi.getAnzGongDate(),
				anSobi.getAnzCuConfirm(),
				anSobi.getAnzCuConfirmTel(),
				anSobi.getAnzCuSmsYn(),
				anSobi.getAnzGongNo(),
				anSobi.getAnzGongName(),
				anSobi.getAnzSignYn(),
				anSobi.getGpsX(),
				anSobi.getGpsY(),
				anSobi.getAppUser());
	}
	
	
	private Map<String, Object> executeAnSobiNew(AnSobi anSobi) {
		return repo.executeSaveAnSobiNew(
				anSobi.getSaveDiv(),
				anSobi.getAreaCode(),
				anSobi.getAnzCuCode(),
				anSobi.getAnzSno(),
				anSobi.getAnzDate(),
				anSobi.getAnzSwCode(),
				anSobi.getAnzSwName(),
				anSobi.getAnzCustName(),
				anSobi.getAnzTel(),
				anSobi.getZipCode(),
				anSobi.getCuAddr1(),
				anSobi.getCuAddr2(),
				anSobi.getAnzA01(),
				anSobi.getAnzA02(),
				anSobi.getAnzA03(),
				anSobi.getAnzA04(),
				anSobi.getAnzA05(),
				anSobi.getAnzB01(),
				anSobi.getAnzB02(),
				anSobi.getAnzB03(),
				anSobi.getAnzB04(),
				anSobi.getAnzB05(),
				anSobi.getAnzC01(),
				anSobi.getAnzC02(),
				anSobi.getAnzC03(),
				anSobi.getAnzC04(),
				anSobi.getAnzC05(),
				anSobi.getAnzC06(),
				anSobi.getAnzC07(),
				anSobi.getAnzC08(),
				anSobi.getAnzGita01(),
				anSobi.getAnzD01(),
				anSobi.getAnzD02(),
				anSobi.getAnzD03(),
				anSobi.getAnzD04(),
				anSobi.getAnzD05(),
				anSobi.getAnzE01(),
				anSobi.getAnzE02(),
				anSobi.getAnzE03(),
				anSobi.getAnzE04(),
				anSobi.getAnzF01(),
				anSobi.getAnzF02(),
				anSobi.getAnzF03(),
				anSobi.getAnzF04(),
				anSobi.getAnzG01(),
				anSobi.getAnzG02(),
				anSobi.getAnzG03(),
				anSobi.getAnzG04(),
				anSobi.getAnzG05(),
				anSobi.getAnzG06(),
				anSobi.getAnzG07(),
				anSobi.getAnzG08(),
				anSobi.getAnzGita02(),
				anSobi.getAnzGa(),
				anSobi.getAnzNa(),
				anSobi.getAnzDa(),
				anSobi.getAnzRa(),
				anSobi.getAnzMa(),
				anSobi.getAnzBa(),
				anSobi.getAnzSa(),
				anSobi.getAnzAa(),
				anSobi.getAnzJa(),
				anSobi.getAnzChaIn(),
				anSobi.getAnzCha(),
				anSobi.getAnzCar(),
				anSobi.getAnzGae01(),
				anSobi.getAnzGae02(),
				anSobi.getAnzGae03(),
				anSobi.getAnzGae04(),
				anSobi.getAnzGongDate(),
				anSobi.getAnzCuConfirm(),
				anSobi.getAnzCuConfirmTel(),
				anSobi.getAnzCuSmsYn(),
				anSobi.getAnzGongNo(),
				anSobi.getAnzGongName(),
				anSobi.getAnzSignYn(),
				anSobi.getGpsX(),
				anSobi.getGpsY(),
				anSobi.getAppUser(),
				anSobi.getAnzFinishDate(),
				anSobi.getAnzCircuitDate());
	}


	private Map<String, Object> executeAnSobiNewAdd(AnSobi anSobi) {
		return repo.executeSaveAnSobiNewAdd(
				anSobi.getSaveDiv(),
				anSobi.getAreaCode(),
				anSobi.getAnzCuCode(),
				anSobi.getAnzSno(),
				anSobi.getAnzDate(),
				anSobi.getAnzSwCode(),
				anSobi.getAnzSwName(),
				anSobi.getAnzCustName(),
				anSobi.getAnzTel(),
				anSobi.getZipCode(),
				anSobi.getCuAddr1(),
				anSobi.getCuAddr2(),
				anSobi.getAnzA01(),
				anSobi.getAnzA02(),
				anSobi.getAnzA03(),
				anSobi.getAnzA04(),
				anSobi.getAnzA05(),
				anSobi.getAnzB01(),
				anSobi.getAnzB02(),
				anSobi.getAnzB03(),
				anSobi.getAnzB04(),
				anSobi.getAnzB05(),
				anSobi.getAnzC01(),
				anSobi.getAnzC02(),
				anSobi.getAnzC03(),
				anSobi.getAnzC04(),
				anSobi.getAnzC05(),
				anSobi.getAnzC06(),
				anSobi.getAnzC07(),
				anSobi.getAnzC08(),
				anSobi.getAnzGita01(),
				anSobi.getAnzD01(),
				anSobi.getAnzD02(),
				anSobi.getAnzD03(),
				anSobi.getAnzD04(),
				anSobi.getAnzD05(),
				anSobi.getAnzE01(),
				anSobi.getAnzE02(),
				anSobi.getAnzE03(),
				anSobi.getAnzE04(),
				anSobi.getAnzF01(),
				anSobi.getAnzF02(),
				anSobi.getAnzF03(),
				anSobi.getAnzF04(),
				anSobi.getAnzG01(),
				anSobi.getAnzG02(),
				anSobi.getAnzG03(),
				anSobi.getAnzG04(),
				anSobi.getAnzG05(),
				anSobi.getAnzG06(),
				anSobi.getAnzG07(),
				anSobi.getAnzG08(),
				anSobi.getAnzGita02(),
				anSobi.getAnzGa(),
				anSobi.getAnzNa(),
				anSobi.getAnzDa(),
				anSobi.getAnzRa(),
				anSobi.getAnzMa(),
				anSobi.getAnzBa(),
				anSobi.getAnzSa(),
				anSobi.getAnzAa(),
				anSobi.getAnzJa(),
				anSobi.getAnzChaIn(),
				anSobi.getAnzCha(),
				anSobi.getAnzCar(),
				anSobi.getAnzCarIn(),
				anSobi.getAnzGae01(),
				anSobi.getAnzGae02(),
				anSobi.getAnzGae03(),
				anSobi.getAnzGae04(),
				anSobi.getAnzGongDate(),
				anSobi.getAnzCuConfirm(),
				anSobi.getAnzCuConfirmTel(),
				anSobi.getAnzCuSmsYn(),
				anSobi.getAnzGongNo(),
				anSobi.getAnzGongName(),
				anSobi.getAnzSignYn(),
				anSobi.getGpsX(),
				anSobi.getGpsY(),
				anSobi.getAppUser(),
				anSobi.getAnzFinishDate(),
				anSobi.getAnzCircuitDate(),
				anSobi.getContFileUrl());
	}



}