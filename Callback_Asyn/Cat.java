package com.hundsun.mobile;

/**
 * Created by Administrator on 2016/1/6.
 */
public class Cat implements Comparable<Cat>{
    String image;//Í¼Æ¬
    int cuteness;//¿É°®Ö¸Êı

    @Override
    public int compareTo(Cat another) {
        return Integer.compare(cuteness,another.cuteness);
    }
}
