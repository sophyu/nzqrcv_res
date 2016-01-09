package com.hundsun.mobile;

import com.sun.jndi.toolkit.url.Uri;

import java.util.List;

/**
 * Created by Administrator on 2016/1/6.
 * ��ʱһ�����⣬�ṩһ���۲��߽ӿڣ�����Ȥ�Ĺ۲���
 * ���Զ��ģ���ʵ������ӿڵĹ۲��ߴ��룡��
 */
public interface Api {
    /**
     * ������ȷ���ߴ�����첽�ص��ӿ�
     * ���ýӿڽ�����ַ����۲��ߴ���
     * ���д�ʱ������֪ͨ���۲���
     */
    interface CatsQueryCallback{
        void onCatListReceived(List<Cat> cats);
        void onError(Exception e);
    }
    //�첽�ӿڡ�֪ͨʽ�ġ�
    //�ַ�������CatsQueryCallback��ɫ�Ķ�����
    void queryCats(String query,CatsQueryCallback catsQueryCallback);
    //ͬ���ӿڲ�ѯcat��ȡ��һ��List������ʽ��
    List<Cat> queryCats(String query);
    Uri store(Cat cat);//�洢������
}
