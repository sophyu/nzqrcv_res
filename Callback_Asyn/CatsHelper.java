package com.hundsun.mobile;

import com.sun.jndi.toolkit.url.Uri;

import java.util.Collections;
import java.util.List;

/**
 * Created by Administrator on 2016/1/6.
 */
public class CatsHelper {
    /**
     * 这里给出定义，当然是有在这里使用这个接口，
     * 这个接口的实现由观察者实现，
     * 观察者获取到主题给它的数据，
     */
    public interface CutestCatCallback{
        //保存成功将uri给出去
        void onCutestCatSaved(Uri uri);
        //查询失败给出异常
        void onQueryFailed(Exception e);
    }
    Api api;
    //异步接口,CutestCatCallbackvoid
    public void saveTheCutestCat(String query,CutestCatCallback cutestCatCallback){
        /**
         * 异步接口
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
    //同步接口
    public Uri saveTheCutestCat(String query){
        /**
         * 必须等待方法的完成
         * 各个方法组合得到结果，前一个返回后一个执行
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
