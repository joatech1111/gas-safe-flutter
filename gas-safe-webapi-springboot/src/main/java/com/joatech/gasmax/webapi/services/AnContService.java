package com.joatech.gasmax.webapi.services;

import java.util.List;
import java.util.Map;

import com.joatech.gasmax.webapi.domains.AnCont;
import com.joatech.gasmax.webapi.domains.AnContRepository;


public class AnContService implements IAnContService{

    private AnContRepository repo;

    public AnContService(String dbHostname, int dbPortNumber, String dbName, String dbUsername, String dbPassword) {
        repo = new AnContRepository(dbHostname, dbPortNumber, dbName, dbUsername, dbPassword);
    }

    public void close() {
        repo.close();
    }

    @Override
    public Map<String, Object> createAnCont(AnCont anCont) {

        anCont.setSaveDiv("I");
        return executeAnCont(anCont);
    }

    // Update
    @Override
    public Map<String, Object> updateAnCont(AnCont anCont) {

        anCont.setSaveDiv("U");
        return executeAnCont(anCont);
    }

    // Delete
    @Override
    public Map<String, Object> deleteAnCont(AnCont anCont) {

        anCont.setSaveDiv("D");
        return executeAnCont(anCont);
    }

    /*
     * 공금계약서 - 점검 이력
     */
    @Override
    public List<Map<String, Object>> getAnContServiceBy(String areaCode, String anzCuCode, String anzSno) {
        return repo.findAllAnContBy(areaCode, anzCuCode, anzSno);
    }

    /*
     * 소비설비 안전점검표 - 신규 등록시 최종점검등록정보
     */
    @Override
    public List<Map<String, Object>> getLastAnContServiceBy(String areaCode, String anzCuCode) {
        return repo.findLastAnContBy(areaCode, anzCuCode);
    }



    private Map<String, Object> executeAnCont(AnCont anCont) {
        return repo.executeSaveAnCont(
                anCont.getSaveDiv(),
                anCont.getAreaCode(),
                anCont.getAnzCuCode(),
                anCont.getAnzSno(),
                anCont.getAnzDate(),
                anCont.getAnzDateF(),
                anCont.getAnzDateT(),

                anCont.getSaleType(),
                anCont.getContType(),
                anCont.getUseCyl(),
                anCont.getUseCylMemo(),
                anCont.getUseMeter(),
                anCont.getUseMeterMemo(),
                anCont.getUseTrans(),
                anCont.getUseTransMemo(),
                anCont.getUseVapor(),
                anCont.getUseVaporMemo(),
                anCont.getUsePipe(),
                anCont.getUsePipeMemo(),
                anCont.getUseFacility(),

                anCont.getCenterSi(),
                anCont.getCenterConsumer(),
                anCont.getCenterKgs(),
                anCont.getCenterGas(),
                anCont.getComBefore(),

                anCont.getComNo(),
                anCont.getComName(),
                anCont.getComTel(),
                anCont.getComHp(),
                anCont.getComCeoName(),
                anCont.getComSignYn(),

                anCont.getCuGongno(),
                anCont.getCustComNo(),
                anCont.getCustComName(),
                anCont.getCuAddr1(),
                anCont.getCuAddr2(),
                anCont.getCustTel(),
                anCont.getCuGongName(),
                anCont.getCustSign(),
                anCont.getContFileUrl(),
                anCont.getAnzCuConfirmTel(),
                anCont.getAnzCuSmsYn(),

                anCont.getRegUserId(),
                anCont.getRegSwCode(),
                anCont.getRegSwName(),
                anCont.getUserno(),
                anCont.getGpsX(),
                anCont.getGpsY(),
                anCont.getRegType());
    }


}
