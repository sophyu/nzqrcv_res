package com.hundsun.mobile;

import com.sun.jndi.toolkit.url.Uri;

import java.util.List;

/**
 * Created by Administrator on 2016/1/6.
 * 这时一个主题，提供一个观察者接口，感兴趣的观察者
 * 可以订阅，将实现这个接口的观察者传入！！
 */
public interface Api {
    /**
     * 返回正确或者错误的异步回调接口
     * 调用接口将结果分发给观察者处理
     * 当有错时将错误通知给观察者
     */
    interface CatsQueryCallback{
        void onCatListReceived(List<Cat> cats);
        void onError(Exception e);
    }
    //异步接口。通知式的。
    //分发给扮演CatsQueryCallback角色的对象处理
    void queryCats(String query,CatsQueryCallback catsQueryCallback);
    //同步接口查询cat获取到一个List，阻塞式的
    List<Cat> queryCats(String query);
    Uri store(Cat cat);//存储到本地
}
