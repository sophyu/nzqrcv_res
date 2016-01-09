package com.hundsun.mobile;

import com.sun.jndi.toolkit.url.Uri;

import java.util.Collections;
import java.util.List;

/**
 * Created by Administrator on 2016/1/6.
 */
public class CatsHelper {
    /**
     * ����������壬��Ȼ����������ʹ������ӿڣ�
     * ����ӿڵ�ʵ���ɹ۲���ʵ�֣�
     * �۲��߻�ȡ��������������ݣ�
     */
    public interface CutestCatCallback{
        //����ɹ���uri����ȥ
        void onCutestCatSaved(Uri uri);
        //��ѯʧ�ܸ����쳣
        void onQueryFailed(Exception e);
    }
    Api api;
    //�첽�ӿ�,CutestCatCallbackvoid
    public void saveTheCutestCat(String query,CutestCatCallback cutestCatCallback){
        /**
         * �첽�ӿ�
         */
        api.queryCats(query,new Api.CatsQueryCallback(){
            @Override
            public void onCatListReceived(List<Cat> cats) {
                Cat cutest = findCutest(cats);
                Uri savedUri = api.store(cutest);
                cutestCatCallback.onCutestCatSaved(savedUri);
            }
            @Override
            public void onError(Exception e) {
                cutestCatCallback.onQueryFailed(e);
            }
        });
    }
    //ͬ���ӿ�
    public Uri saveTheCutestCat(String query){
        /**
         * ����ȴ����������
         * ����������ϵõ������ǰһ�����غ�һ��ִ��
         */
        List<Cat> cats = api.queryCats(query);
        Cat cutest = findCutest(cats);
        Uri saveUri = api.store(cutest);
        return saveUri;
    }
    private Cat findCutest(List<Cat> cats){
        return Collections.max(cats);
    }
}
