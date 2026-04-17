package com.joatech.gasmax.webapi.domains;
import java.util.List;
import java.util.Map;

import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


/*
 * 공급계약등록 Select View
 */
public class AnContRepository  extends GasMaxRepository {

    /*================================================================
     * Private Members
     ================================================================*/
    private final Logger logger = LoggerFactory.getLogger(getClass());

    public AnContRepository(String dbHostname, int dbPortNumber, String dbName, String dbUsername,
                            String dbPassword) {
        super(dbHostname, dbPortNumber, dbName, dbUsername, dbPassword);
        init();
    }

    public Map<String, Object> executeSaveAnCont(String saveDiv, String areaCode, String anzCuCode, String anzSno, String anzDate, String anzDateF, String anzDateT,
                                                 String saleType, String contType, String useCyl, String userCylMemo, String useMeter, String useMeterMemo,
                                                 String useTrans, String useTransMemo, String useVapor, String useVaporMemo, String usePipe, String usePipeMemo,
                                                 String useFacility, String centerSi, String centerConsumer, String centerKgs, String centerGas, String comBefore, String comNo,
                                                 String comName, String comTel, String comHp, String comCeoName, String comSignYn,
                                                 String cuGongno, String custComNo, String custComName, String cuAddr1, String cuAddr2, String custTel, String cuGongname,
                                                 String custSign, String contFileUrl, String anzCuConfirmTel, String anzCuSmsYn,  String regUserId, String regSwCode, String regSwName, String userno,
                                                 String gpsX, String gpsY, String regType){

        SimpleJdbcCall simpleJdbcCall = new SimpleJdbcCall(jdbcTemplate);

        String procedureName = "SP_SAVE_ANCont";
        simpleJdbcCall.withProcedureName(procedureName);

        SqlParameterSource inputParam = new MapSqlParameterSource()
                .addValue("pi_SAVE_DIV", saveDiv)
                .addValue("pi_Area_Code", areaCode)
                .addValue("pi_ANZ_Cu_Code", anzCuCode)
                .addValue("pi_ANZ_Sno", anzSno)
                .addValue("pi_ANZ_Date", anzDate)
                .addValue("pi_ANZ_Date_F", anzDateF)
                .addValue("pi_ANZ_Date_T", anzDateT)

                .addValue("pi_SALE_TYPE", saleType)
                .addValue("pi_CONT_TYPE", contType)
                .addValue("pi_USE_CYL", useCyl)
                .addValue("pi_USE_CYL_MEMO", userCylMemo)
                .addValue("pi_USE_METER", useMeter)
                .addValue("pi_USE_METER_MEMO", useMeterMemo)
                .addValue("pi_USE_TRANS", useTrans)
                .addValue("pi_USE_TRANS_MEMO", useTransMemo)
                .addValue("pi_USE_VAPOR", useVapor)
                .addValue("pi_USE_VAPOR_MEMO", useVaporMemo)
                .addValue("pi_USE_PIPE", usePipe)
                .addValue("pi_USE_PIPE_MEMO", usePipeMemo)
                .addValue("pi_USE_Facility", useFacility)

                .addValue("pi_CENTER_SI", centerSi)
                .addValue("pi_CENTER_Consumer", centerConsumer)
                .addValue("pi_CENTER_KGS", centerKgs)
                .addValue("pi_CENTER_GAS", centerGas)
                .addValue("pi_COM_BEFORE", comBefore)


                .addValue("pi_COM_NO", comNo)
                .addValue("pi_COM_NAME", comName)
                .addValue("pi_COM_TEL", comTel)
                .addValue("pi_COM_HP", comHp)
                .addValue("pi_COM_CEO_NAME", comCeoName)
                .addValue("pi_COM_SIGN_YN", comSignYn)

                .addValue("pi_CU_GONGNO", cuGongno)
                .addValue("pi_CUST_COM_NO", custComNo)
                .addValue("pi_CUST_COM_NAME", custComName)
                .addValue("pi_CU_ADDR1", cuAddr1)
                .addValue("pi_CU_ADDR2", cuAddr2)
                .addValue("pi_CUST_TEL", custTel)
                .addValue("pi_CU_GONGNAME", cuGongname)
                .addValue("pi_CUST_SIGN", custSign)
                .addValue("pi_CONT_FILE_URL", contFileUrl)
                .addValue("pi_ANZ_CU_Confirm_TEL", anzCuConfirmTel)
                .addValue("pi_ANZ_CU_SMS_YN", anzCuSmsYn)

                .addValue("pi_REG_USER_ID", regUserId)
                .addValue("pi_REG_SW_CODE", regSwCode)
                .addValue("pi_REG_SW_NAME", regSwName)
                .addValue("pi_USERNO", userno)

                .addValue("pi_GPS_X", gpsX)
                .addValue("pi_GPS_Y", gpsY)
                .addValue("pi_REG_TYPE", regType);

        Map<String, Object> out = simpleJdbcCall.execute(inputParam);

        return out;

    }

    public List<Map<String, Object>> findAllAnContBy(String areaCode, String anzCuCode, String anzSno){

        String queryString = String.format("SELECT * FROM FN_SELECT_ANCONT('%s', '%s', '%s')", areaCode, anzCuCode, anzSno);
        List<Map<String, Object>> result = jdbcTemplate.queryForList(queryString);
        return result;
    }

    public List<Map<String, Object>> findLastAnContBy(String areaCode, String anzCuCode){

        String queryString = String.format("SELECT * FROM fn_Select_ANCont_Defult('%s', '%s', '')", areaCode, anzCuCode);
        List<Map<String, Object>> result = jdbcTemplate.queryForList(queryString);
        return result;
    }

}
