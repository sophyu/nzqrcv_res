package com.hundsun.mobile;

/**
 * Created by Administrator on 2016/1/6.
 */
public class Cat implements Comparable<Cat>{
    String image;//ͼƬ
    int cuteness;//�ɰ�ָ��

    @Override
    public int compareTo(Cat another) {
        return Integer.compare(cuteness,another.cuteness);
    }
}
