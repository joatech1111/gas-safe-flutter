package com.joatech.gasmax.webapi;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;

import com.joatech.gasmax.webapi.configurations.GasMaxConfig;
import com.joatech.gasmax.webapi.domains.AppUserSafe;
import com.joatech.gasmax.webapi.services.AnSobiSafeService;
import com.joatech.gasmax.webapi.services.AnSobiService;
import com.joatech.gasmax.webapi.services.AnSobiTankService;
import com.joatech.gasmax.webapi.services.AppUserSafeService;
import com.joatech.gasmax.webapi.services.ComboBoxSectionKeywordService;
import com.joatech.gasmax.webapi.services.ComboBoxTypeService;
import com.joatech.gasmax.webapi.services.SMSNoticesService;
import com.joatech.gasmax.webapi.services.SearchSafeCustomerService;
import com.joatech.gasmax.webapi.services.UserSessionService;

@RunWith(SpringRunner.class)
@SpringBootTest
public class JoatechGasmaxWebapiApplicationTests {

	@Autowired
	UserSessionService userSessionService;

	@Autowired
	GasMaxConfig gasMaxConfig;

	@Autowired
	AppUserSafeService appUserSafeService;
	
	@Test
	public void userSessionTest() {
		Optional<AppUserSafe> optAppUserSafe = null;
		try {
			optAppUserSafe = appUserSafeService.getAppUserSafeByHpImei("355325070280849");
		} catch(Exception e) {
			e.printStackTrace();
		}
		AppUserSafe appUserSafe = optAppUserSafe.orElse(null);
		System.out.println(appUserSafe);
		
		String sessionId = userSessionService.makeNewSession(appUserSafe);
		System.out.println(sessionId);
		
		try {
			Thread.sleep(3000);
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
		long ttl = userSessionService.getSessionTTL(sessionId);
		System.out.println(ttl);

		AppUserSafe getSessionInfo = userSessionService.getSessionInfo(sessionId); 
		System.out.println(getSessionInfo);
		ttl = userSessionService.getSessionTTL(sessionId);
		System.out.println(ttl);
	}

	@Test
	public void appUserSafeTest() {

		Optional<AppUserSafe> optAppUserSafe = null;
		try {
			optAppUserSafe = appUserSafeService.getAppUserSafeByHpImei("355325070280849");
		} catch(Exception e) {
			e.printStackTrace();
		}
		AppUserSafe appUserSafe = optAppUserSafe.orElse(null);
		System.out.println(appUserSafe);
		
		String result = appUserSafeService.getAppUserSafeAuthenticateInfo(appUserSafe.getHpImei(), appUserSafe.getHpModel(), appUserSafe.getHpSNo(), appUserSafe.getAppVersion(), appUserSafe.getLoginCo(), appUserSafe.getLoginName(), appUserSafe.getLoginUser(), appUserSafe.getLoginPassword());
		System.out.println(result);
		
		SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		appUserSafeService.updateAppUserSafe(appUserSafe.getAppVersion(), dateFormat.format(new Date()), appUserSafe.getHpImei());

		List<AppUserSafe> appUserSafeList = appUserSafeService.getAllAppUserSafe();
		System.out.println(appUserSafeList);

		ComboBoxTypeService comboService = new ComboBoxTypeService(
				appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword()
			);
		List<Map<String, Object>> output = comboService.getAllComboTypeListByAreaCode(appUserSafe.getBaAreaCode());
		System.out.println(output);
		output = comboService.getAreaComboTypeList();
		System.out.println(output);

		comboService.close();
		
	}
	
	/*
	 * 점검 거래처 검색 
	 */
	@Test
	public void fnMeterCuFindTest() {
		Optional<AppUserSafe> optAppUserSafe = null;
		try {
			optAppUserSafe = appUserSafeService.getAppUserSafeByHpImei("355325070280849");
		} catch(Exception e) {
			e.printStackTrace();
		}
		AppUserSafe appUserSafe = optAppUserSafe.orElse(null);
		System.out.println(appUserSafe);
/*
		MeterCustomerService searchMeterCustomerService = new MeterCustomerService(
				appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
		

		
		List<Map<String, Object>> output = searchMeterCustomerService.getAllSearchMeterCustomerListBy(appUserSafe.getBaAreaCode(), "금남", "", "", "", "", "", "", "", "", "", "", "", "", "",""); 
		System.out.println(output);
		 
		
		output = searchMeterCustomerService.getSNoSearchMeterCustomerListBy(appUserSafe.getBaAreaCode(), "", "20191001", "", "", "", "", "", "", "", "", "", "", "", "", "");
		System.out.println(output);
		
		output = searchMeterCustomerService.getTurmSearchMeterCustomerListBy(appUserSafe.getBaAreaCode(), "", "20191001", "", "", "", "", "", "", "", "", "", "", "", "", "");
		System.out.println(output);
		
		output = searchMeterCustomerService.getGpsSearchMeterCustomerListBy(appUserSafe.getBaAreaCode(), "", "20191001", "", "", "", "", "", "", "", "", "", "", "", "", "");
		System.out.println(output);*/

		/*
		 * List<Map<String, Object>> output =
		 * searchRepo.findAllMeterCustomerBy(appUserSafe.getBaAreaCode(), "금남", "", "",
		 * "", "", "", "", "", "", "", "", "", "", "", ""); System.out.println(output);
		 * 
		 * output = searchRepo.findSNoMeterCustomerBy(appUserSafe.getBaAreaCode(), "",
		 * "20191001", "", "", "", "", "", "", "", "", "", "", "", "", "");
		 * System.out.println(output);
		 * 
		 * output = searchRepo.findTurmMeterCustomerBy(appUserSafe.getBaAreaCode(), "",
		 * "20191001", "", "", "", "", "", "", "", "", "", "", "", "", "");
		 * System.out.println(output);
		 * 
		 * output = searchRepo.findGpsMeterCustomerBy(appUserSafe.getBaAreaCode(), "",
		 * "20191001", "", "", "", "", "", "", "", "", "", "", "", "", "");
		 * System.out.println(output);
		 */
		
	}

	/*
	 * 점검 검색어 검색(FN_점검 검색어 검색)
	 */
	@Test
	public void fnSearchSafeCustomerFindTest() {
		Optional<AppUserSafe> optAppUserSafe = null;
		try {
			optAppUserSafe = appUserSafeService.getAppUserSafeByHpImei("355325070280849");
		} catch(Exception e) {
			e.printStackTrace();
		}
		AppUserSafe appUserSafe = optAppUserSafe.orElse(null);
		System.out.println(appUserSafe);

		SearchSafeCustomerService searchSafeCustomerService = new SearchSafeCustomerService(
				appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
		
		/*
		 * List<Map<String, Object>> output =
		 * searchSafeCustomerService.getAllSearchSafeCustomerBy(appUserSafe.
		 * getBaAreaCode(), "", "", "", "", "", "", "", "", "", "", "", "", "");
		 * System.out.println(output);
		 * 
		 * output = searchSafeCustomerService.getGpsAllSearchSafeCustomerBy(appUserSafe.
		 * getBaAreaCode(), "", "", "", "", "", "", "", "", "", "", "", "", "");
		 * System.out.println(output);
		 */

		/*
		 * List<Map<String, Object>> output =
		 * searchSafeRepo.findSafeCustomerBy(appUserSafe.getBaAreaCode(), "금남", "", "",
		 * "", "", "", "", "", "", "", "", "", ""); System.out.println(output);
		 * 
		 * output = searchSafeRepo.findGpsSafeCustomerBy(appUserSafe.getBaAreaCode(),
		 * "", "", "", "", "", "", "", "", "", "", "", "", "");
		 * System.out.println(output);
		 */
		
	}
	
	/*
	 * 구분별 검색어 콤보박스 설정(FN 검색정보 List)
	 */
	@Test
	public void fnComboSectionKeywordFindTest() {
		Optional<AppUserSafe> optAppUserSafe = null;
		try {
			optAppUserSafe = appUserSafeService.getAppUserSafeByHpImei("355325070280849");
		} catch(Exception e) {
			e.printStackTrace();
		}
		AppUserSafe appUserSafe = optAppUserSafe.orElse(null);
		System.out.println(appUserSafe);
		
		ComboBoxSectionKeywordService comboSectionKeywordService = new ComboBoxSectionKeywordService(
				appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
			
		List<Map<String, Object>> output = comboSectionKeywordService.getAllComboAptListByAreaCode(appUserSafe.getBaAreaCode());
		System.out.println(output);

		output = comboSectionKeywordService.getAllComboAptListByAreaCodeAndKeyword(appUserSafe.getBaAreaCode(), "현대");
		System.out.println(output);
		
		output = comboSectionKeywordService.getAllComboGumListByAreaCode(appUserSafe.getBaAreaCode());
		System.out.println(output);
		
		output = comboSectionKeywordService.getAllComboMeterListByAreaCode(appUserSafe.getBaAreaCode());
		System.out.println(output);
	
	}
	
	/*
	 * SMS 
	 */
	@Test
	public void fnSafeSmsMsgFindTest() {
		
		Optional<AppUserSafe> optAppUserSafe = null;
		try {
			optAppUserSafe = appUserSafeService.getAppUserSafeByHpImei("355325070280849");
		} catch(Exception e) {
			e.printStackTrace();
		}
		AppUserSafe appUserSafe = optAppUserSafe.orElse(null);
		System.out.println(appUserSafe);
		
		SMSNoticesService smsNoticesService = new SMSNoticesService(
				appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
		
		/*
		 * Map<String, Object> output =
		 * smsNoticesService..getSMSNoticesByAreaCodeAndSmsDiv(appUserSafe.getBaAreaCode
		 * ()); System.out.println(output);
		 */
		
		
		/*
		 * SMSNoticesRepository smsNoticesRepository = new SMSNoticesRepository(
		 * appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()),
		 * appUserSafe.getServerDBName(), appUserSafe.getServerUser(),
		 * appUserSafe.getServerPassword());
		 * 
		 * List<Map<String, Object>> output =
		 * smsNoticesRepository.findSmsNoticesSafeBy(appUserSafe.getBaAreaCode());
		 * System.out.println(output);
		 */
	}
	
	/*
	 * 검침현황(FN 검침현황)
	 */
	@Test
	public void fnMeterInsertListTest() {
		
		Optional<AppUserSafe> optAppUserSafe = null;
		try {
			optAppUserSafe = appUserSafeService.getAppUserSafeByHpImei("355325070280849");
		} catch(Exception e) {
			e.printStackTrace();
		}
		AppUserSafe appUserSafe = optAppUserSafe.orElse(null);
		System.out.println(appUserSafe);
		
		//MeterInsertService meterInsertService = new MeterInsertService(
				//appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
		
		/*
		 * List<Map<String, Object>> output =
		 * meterInsertService.getAllMeterInsertServiceBy(appUserSafe.getBaAreaCode(),
		 * "", "", "", "", "", "", "", "", "", "", "", ""); System.out.println(output);
		 * 
		 * output =
		 * meterInsertService.getGpsMeterInsertServiceBy(appUserSafe.getBaAreaCode(),
		 * "", "", "", "", "", "", "", "", "", "", "", ""); System.out.println(output);
		 */
		
		/*
		 * List<Map<String, Object>> output =
		 * meterInsertRepository.findMeterInsertListBy(appUserSafe.getBaAreaCode(), "",
		 * "", "", "", "", "", "", "", "", "", "", ""); System.out.println(output);
		 * 
		 * output =
		 * meterInsertRepository.findGpsMeterInsertListBy(appUserSafe.getBaAreaCode(),
		 * "", "", "", "", "", "", "", "", "", "", "", ""); System.out.println(output);
		 */
	}
	
	/*
	 * 소비설비 안전점검표 Select View(소비 설비 이력 Select)
	 */
	@Test
	public void fnSelectAnSobiTest() {
		
		Optional<AppUserSafe> optAppUserSafe = null;
		try {
			optAppUserSafe = appUserSafeService.getAppUserSafeByHpImei("355325070280849");
		} catch(Exception e) {
			e.printStackTrace();
		}
		AppUserSafe appUserSafe = optAppUserSafe.orElse(null);
		System.out.println(appUserSafe);
		
		AnSobiService selectAnSobiService = new AnSobiService(
				appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
		
		List<Map<String, Object>> output = selectAnSobiService.getAnSobiServiceBy(appUserSafe.getBaAreaCode(), "", "");
		System.out.println(output);
		
		/*
		 * output =
		 * selectAnSobiService.getLastAnSobiServiceBy(appUserSafe.getBaAreaCode(), "",
		 * ""); System.out.println(output);
		 */
		
		/*
		 * List<Map<String, Object>> output =
		 * selectAnSobiRepository.findSelectAnSobiBy(appUserSafe.getBaAreaCode(), "",
		 * ""); System.out.println(output);
		 * 
		 * output =
		 * selectAnSobiRepository.findLastSelectAnSobiBy(appUserSafe.getBaAreaCode(),
		 * "", ""); System.out.println(output);
		 */
		
	}
	
	/*
	 *  저장탱크 안전점검표 Select View(탱크 점검 Select)
	 */
	@Test
	public void fnSelectAnSobiTankTest() {
		
		Optional<AppUserSafe> optAppUserSafe = null;
		try {
			optAppUserSafe = appUserSafeService.getAppUserSafeByHpImei("355325070280849");
		} catch(Exception e) {
			e.printStackTrace();
		}
		AppUserSafe appUserSafe = optAppUserSafe.orElse(null);
		System.out.println(appUserSafe);
		
		AnSobiTankService selectAnSobiTankService = new AnSobiTankService(
				appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
		
		List<Map<String, Object>> output = selectAnSobiTankService.getAnSobiTankServiceBy(appUserSafe.getBaAreaCode(), "", "");
		System.out.println(output);
		
		/*
		 * output =
		 * selectAnSobiTankService.getLastAnSobiTankServiceBy(appUserSafe.getBaAreaCode(
		 * ), "", ""); System.out.println(output);
		 */
		
		/*
		 * List<Map<String, Object>> output =
		 * selectAnSobiTankRepository.findSelectAnSobiTankBy(appUserSafe.getBaAreaCode()
		 * , "", ""); System.out.println(output);
		 * 
		 * output = selectAnSobiTankRepository.findLastSelectAnSobiTankBy(appUserSafe.
		 * getBaAreaCode(), "", ""); System.out.println(output);
		 */
	}
	
	/*
	 * 사용시설점검 Select View
	 */
	@Test
	public void fnSelectAnSobiSafeTest() {
		
		Optional<AppUserSafe> optAppUserSafe = null;
		try {
			optAppUserSafe = appUserSafeService.getAppUserSafeByHpImei("355325070280849");
		} catch(Exception e) {
			e.printStackTrace();
		}
		AppUserSafe appUserSafe = optAppUserSafe.orElse(null);
		System.out.println(appUserSafe);
		
		AnSobiSafeService selectAnSobiSafeService = new AnSobiSafeService(
				appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()), appUserSafe.getServerDBName(), appUserSafe.getServerUser(), appUserSafe.getServerPassword());
		
		List<Map<String, Object>> output = selectAnSobiSafeService.getAnSobiSafeServiceBy(appUserSafe.getBaAreaCode(), "", "");
		System.out.println(output);
		
		/*
		 * output =
		 * selectAnSobiSafeService.getLastAnSobiSafeBy(appUserSafe.getBaAreaCode(), "",
		 * ""); System.out.println(output);
		 */
		
		/*
		 * List<Map<String, Object>> output =
		 * selectAnSobiSafeRepository.findSelectAnSobiSafeBy(appUserSafe.getBaAreaCode()
		 * , "", ""); System.out.println(output);
		 * 
		 * output = selectAnSobiSafeRepository.findLastSelectAnSobiSafeBy(appUserSafe.
		 * getBaAreaCode(), "", ""); System.out.println(output);
		 */
	}
	
	/*
	 * 점검현황(FN점검현황 )
	 */
	@Test
	public void fnSsfeInsertListTest() {
		
		Optional<AppUserSafe> optAppUserSafe = null;
		try {
			optAppUserSafe = appUserSafeService.getAppUserSafeByHpImei("355325070280849");
		} catch(Exception e) {
			e.printStackTrace();
		}
		AppUserSafe appUserSafe = optAppUserSafe.orElse(null);
		System.out.println(appUserSafe);
		
		/*
		 * SafeInsertListService safeInsertListService = new SafeInsertListService(
		 * appUserSafe.getServerIp(), Integer.parseInt(appUserSafe.getServerPort()),
		 * appUserSafe.getServerDBName(), appUserSafe.getServerUser(),
		 * appUserSafe.getServerPassword());
		 */
		
		/*
		 * List<Map<String, Object>> output =
		 * safeInsertListService.getSafeInsertListServiceBy(appUserSafe.getBaAreaCode(),
		 * "", "", "", "", "", "", "", "", "", "", "", "", "", "");
		 * System.out.println(output);
		 * 
		 * output = safeInsertListService.getGpsSafeInsertListeServiceBy(appUserSafe.
		 * getBaAreaCode(), "", "", "", "", "", "", "", "", "", "", "", "", "", "");
		 * System.out.println(output);
		 */
		
		/*
		 * List<Map<String, Object>> output =
		 * safeInsertListRepository.findSafeInsertListBy(appUserSafe.getBaAreaCode(),
		 * "", "", "", "", "", "", "", "", "", "", "", "", "", "");
		 * System.out.println(output);
		 * 
		 * output =
		 * safeInsertListRepository.findGpsSafeInsertListBy(appUserSafe.getBaAreaCode(),
		 * "", "", "", "", "", "", "", "", "", "", "", "", "", "");
		 * System.out.println(output);
		 */
	}
}
