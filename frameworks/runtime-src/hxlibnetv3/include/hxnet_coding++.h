#ifndef __HXNET_CODING_PLUSPLUS_H__
#define __HXNET_CODING_PLUSPLUS_H__

#pragma once

#include <stddef.h>
#include <stdint.h>
#include <string.h>

#ifndef __HX_PLATFORM_H__
typedef char			achar_t;
#endif//

#define LAVE_LEN (pos>=len?0:len-pos)
#define LAVE_BUF (buf+pos)
#define SET_TYPE(f,t) (buf?(*(buf+pos++)=((f)&0xFF)<<3|t):pos++)
#define CHK_LEN(l) (((uint32_t)pos+(l)) > len)

typedef enum wire_type {
    EWIRE_VARIA = 0,
    EWIRE_FIX16,
    EWIRE_FIX32,
    EWIRE_FIX64,
    EWIRE_ANY,
    EWIRE_MAX = EWIRE_ANY,
}wire_e;

template<size_t v>
struct _ChgT {
    enum {
        _Offset = 31,
    };
};

template<>
struct _ChgT<8> {
    enum {
        _Offset = 63,
    };
};

template<class _Ty>
int32_t EncodeBase128(const _Ty* val, uint8_t* buf, uint32_t len) {
    typedef _ChgT<sizeof(_Ty)> _ChgTy;
    _Ty z;
    int32_t pos = 0;
    uint8_t v = 0;
    memcpy(&z,val,sizeof(_Ty));
    z = ((z << 1) ^ (z >> _ChgTy::_Offset)); //ZigZag (hex)
    do {
        if(CHK_LEN(1))
            break;
        v = z >= 0x80?0x80:0;
        if(NULL!=buf) (*LAVE_BUF) = (uint8_t)((z|v) & 0xFF);
        pos++;
        z >>= 7;
    }while(pos < len && v == 0x80);
    return pos;
}

template<>
int32_t EncodeBase128<float>(const float* val, uint8_t* buf, uint32_t len) {
    if(len < sizeof(float)) return 0;
    if(NULL!=buf) memcpy(buf,val,sizeof(float));
    return sizeof(float);
}

template<>
int32_t EncodeBase128<double>(const double* val, uint8_t* buf, uint32_t len) {
    if(len < sizeof(double)) return 0;
    if(NULL!=buf) memcpy(buf,val,sizeof(double));
    return sizeof(double);
}

template<>
int32_t EncodeBase128<int8_t>(const int8_t* val, uint8_t* buf, uint32_t len) {
    if(len < sizeof(int8_t)) return 0;
    if(NULL!=buf) memcpy(buf,val,sizeof(int8_t));
    return sizeof(int8_t);
}

template<>
int32_t EncodeBase128<uint8_t>(const uint8_t* val, uint8_t* buf, uint32_t len) {
    if(len < sizeof(uint8_t)) return 0;
    if(NULL!=buf) memcpy(buf,val,sizeof(int8_t));
    return sizeof(uint8_t);
}

//-------------------------------------------------------------------------------------------------------
template<class _Ty>
int32_t DecodeBase128(_Ty* val, const uint8_t* buf, uint32_t len) {
    typedef _ChgT<sizeof(_Ty)> _ChgTy;
    _Ty z = 0;
    int32_t pos = 0;
    uint8_t v = 0;
    do {
        int offset = pos*7;
        if(CHK_LEN(1))
            break;
        v = (*LAVE_BUF)&0xFF;
        pos++;
        z |= ((_Ty)(v & ~0x80) << offset);
    }while(v >= 0x80);
    *val = ((z >> 1) ^ -(z & 1)); //ZigZag (hex)
    return pos;
}

template<>
int32_t DecodeBase128<float>(float* val, const uint8_t* buf, uint32_t len) {
    int32_t pos = 0;
    if(len >= sizeof(float)){
        memcpy(val,buf,sizeof(float));
        pos = sizeof(float);
    }
    return pos;
}

template<>
int32_t DecodeBase128<double>(double* val, const uint8_t* buf, uint32_t len) {
    int32_t pos = 0;
    if(len >= sizeof(double)){
        memcpy(val,buf,sizeof(double));
        pos = sizeof(double);
    }
    return pos;
}

template<>
int32_t DecodeBase128<int8_t>(int8_t* val, const uint8_t* buf, uint32_t len) {
    int32_t pos = 0;
    if(len >= sizeof(int8_t)){
        memcpy(val,buf,sizeof(int8_t));
        pos = sizeof(int8_t);
    }
    return pos;
}

template<>
int32_t DecodeBase128<uint8_t>(uint8_t* val, const uint8_t* buf, uint32_t len) {
    int32_t pos = 0;
    if(len >= sizeof(uint8_t)){
        memcpy(val,buf,sizeof(uint8_t));
        pos = sizeof(uint8_t);
    }
    return pos;
}




template<class _Ty>
int32_t EncodeField( int32_t field, const _Ty* val, int32_t count, uint8_t* buf, uint32_t len) {
    int32_t pos = 0;
    int32_t ops = 0;
    if(count < 0){
        SET_TYPE(field, EWIRE_VARIA);
        pos += EncodeBase128(val, LAVE_BUF, LAVE_LEN);
        return pos;
    }
    SET_TYPE(field, EWIRE_ANY);
    uint16_t& sz = *(uint16_t*)LAVE_BUF;
    pos += sizeof(uint16_t);
    ops = pos;
    for(int32_t i=0;i<count;i++) {
        pos += EncodeBase128(val+i, LAVE_BUF, LAVE_LEN);
    }
    sz=pos-ops;
    return pos;
}
template<>
int32_t EncodeField<achar_t>( int32_t field, const achar_t* val, int32_t count, uint8_t* buf, uint32_t len) {
    int32_t pos = 0;
    int32_t ops = 0;
    if(count < 0){
        SET_TYPE(field, EWIRE_VARIA);
        memcpy(LAVE_BUF, val, sizeof(achar_t));
        pos+=sizeof(achar_t);
        return pos;
    }
    SET_TYPE(field, EWIRE_ANY);
    uint16_t& sz = *(uint16_t*)LAVE_BUF;
    pos += sizeof(uint16_t);
    ops = pos;
    for(int32_t i=0;i<count;i++) {
        memcpy(LAVE_BUF, val+i, sizeof(achar_t));
        pos+=sizeof(achar_t);
        if(0 == *(val+i)){ //多加一个字节
            break;
        }
    }
    sz = pos - ops;
    return pos;
}

template<>
int32_t EncodeField<int8_t>( int32_t field, const int8_t* val, int32_t count, uint8_t* buf, uint32_t len) {
    int32_t pos = 0;
    int32_t ops = 0;
    if(count < 0){
        SET_TYPE(field, EWIRE_VARIA);
        memcpy(LAVE_BUF, val, sizeof(int8_t));
        pos+=sizeof(int8_t);
        return pos;
    }
    SET_TYPE(field, EWIRE_ANY);
    uint16_t& sz = *(uint16_t*)LAVE_BUF;
    pos += sizeof(uint16_t);
    ops = pos;
    for(int32_t i=0;i<count;i++) {
        memcpy(LAVE_BUF, val+i, sizeof(int8_t));
        pos+=sizeof(int8_t);
        if(0 == *(val+i)){ //多加一个字节
            break;
        }
    }
    sz = pos - ops;
    return pos;
}

template<>
int32_t EncodeField<uint8_t>( int32_t field, const uint8_t* val, int32_t count, uint8_t* buf, uint32_t len) {
    int32_t pos = 0;    
    int32_t ops = 0;
    if(count < 0){
        SET_TYPE(field, EWIRE_VARIA);
        memcpy(LAVE_BUF, val, sizeof(uint8_t));
        pos+=sizeof(uint8_t);
        return pos;
    }
    SET_TYPE(field, EWIRE_ANY);
    uint16_t& sz = *(uint16_t*)LAVE_BUF;
    pos += sizeof(uint16_t);
    ops = pos;
    for(int32_t i=0;i<count;i++) {
        memcpy(LAVE_BUF, val + i, sizeof(uint8_t));
        pos+=sizeof(uint8_t);
    }
    sz = pos - ops;
    return pos;
}

template<class _Ty>
int32_t DecodeField(int32_t* field, _Ty* val, int32_t* count, const uint8_t* buf, uint32_t len) {
    int32_t pos = 0;
    uint8_t tag;
    int32_t cnt = 0;
    *field = -1;
    if(len <=0) return 0;
    memcpy(&tag, buf, sizeof(uint8_t));
    *field = (int32_t)(tag>>3);
    pos++;
    if(CHK_LEN(1)) {
        if(count)*count = -1;
        return pos;
    }
    if((tag&7)!=EWIRE_ANY) {
        if(count)*count = -1;
        pos += DecodeBase128(val, LAVE_BUF, LAVE_LEN);
        return pos;
    }
    if(CHK_LEN(sizeof(uint16_t))) {
        if(count)*count = -1;
        return pos;
    }
    memcpy(&cnt, LAVE_BUF, sizeof(uint16_t));
    pos += sizeof(uint16_t);
    *count = 0;
    for(int32_t i = 0; pos < len && cnt > 0; i++) {
        int32_t dsz =  DecodeBase128(val + i, LAVE_BUF, LAVE_LEN);
        (*count)++;
        cnt -= dsz;
        pos += dsz;
    }
    return pos;
}
template<>
int32_t DecodeField<achar_t>(int32_t* field, achar_t* val, int32_t* count, const uint8_t* buf, uint32_t len) {
    int32_t pos = 0;
    uint8_t tag;
    int32_t cnt = 0;
    *field = -1;
    if(len <=0) return 0;
    memcpy(&tag, buf, sizeof(uint8_t));
    *field = (int32_t)(tag>>3);
    pos++;
    if(CHK_LEN(1)) {
        if(count)*count = -1;
        return pos;
    }
    if((tag&7)!=EWIRE_ANY) {
        if(count)*count = -1;
        memcpy(val,LAVE_BUF,sizeof(achar_t));
        pos += sizeof(achar_t);
        return pos;
    }
    if(CHK_LEN(sizeof(uint16_t))) {
        if(count)*count = -1;
        return pos;
    }
    memcpy(&cnt, LAVE_BUF, sizeof(uint16_t));
    pos += sizeof(uint16_t);
    *count = 0;
    for(int32_t i = 0; pos < len && cnt > 0; i++) {
        memcpy(val+i, LAVE_BUF, sizeof(achar_t));
        if(count) (*count)++;
        cnt -= sizeof(achar_t);
        pos += sizeof(achar_t);
    }
    return pos;
}

template<>
int32_t DecodeField<int8_t>(int32_t* field, int8_t* val, int32_t* count, const uint8_t* buf, uint32_t len) {
    int32_t pos = 0;
    uint8_t tag;
    int32_t cnt = 0;
    *field = -1;
    if(len <=0) return 0;
    memcpy(&tag, buf, sizeof(uint8_t));
    *field = (int32_t)(tag>>3);
    pos++;
    if(CHK_LEN(1)) {
        if(count)*count = -1;
        return pos;
    }
    if((tag&7)!=EWIRE_ANY) {
        if(count)*count = -1;
        memcpy(val,LAVE_BUF,sizeof(int8_t));
        pos += sizeof(int8_t);
        return pos;
    }
    if(CHK_LEN(sizeof(uint16_t))) {
        if(count)*count = -1;
        return pos;
    }
    memcpy(&cnt, LAVE_BUF, sizeof(uint16_t));
    pos += sizeof(uint16_t);
    *count = 0;
    for(int32_t i = 0; pos < len && cnt > 0; i++) {
        memcpy(val+i, LAVE_BUF, sizeof(int8_t));
        if(count) (*count)++;
        cnt -= sizeof(int8_t);
        pos += sizeof(int8_t);
    }
    return pos;
}
template<>
int32_t DecodeField<uint8_t>(int32_t* field, uint8_t* val, int32_t* count, const uint8_t* buf, uint32_t len) {
    int32_t pos = 0;
    uint8_t tag;
    int32_t cnt = 0;
    *field = -1;
    if(len <=0) return 0;
    memcpy(&tag, buf, sizeof(uint8_t));
    *field = (int32_t)(tag>>3);
    pos++;
    if(CHK_LEN(1)) {
        if(count)*count = -1;
        return pos;
    }
    if((tag&7)!=EWIRE_ANY) {
        if(count)*count = -1;
        memcpy(val,LAVE_BUF,sizeof(int8_t));
        pos += sizeof(int8_t);
        return pos;
    }
    if(CHK_LEN(sizeof(uint16_t))) {
        if(count)*count = -1;
        return pos;
    }
    memcpy(&cnt, LAVE_BUF, sizeof(uint16_t));
    pos += sizeof(uint16_t);
    *count = 0;
    for(int32_t i = 0; pos < len && cnt > 0; i++) {
        memcpy(val+i, LAVE_BUF, sizeof(uint8_t));
        if(count) (*count)++;
        cnt -= sizeof(uint8_t);
        pos += sizeof(uint8_t);
    }
    return pos;
}


template<class _Ty,int _Test>
struct CodingHelper{
    typedef _Ty*        rtype;
    typedef const _Ty*  ctype;
    inline static int32_t Encode(int32_t field, ctype val, int32_t count, uint8_t* buf, uint32_t len) {
        return EncodeField(field, val, count>0?count:_Test, buf, len);
    }
    inline static int32_t Decode(int32_t* field, rtype des, int32_t* count, const uint8_t* buf, uint32_t len) {
        return DecodeField(field, des, count, buf, len);
    }
};

template<class _Ty>
struct CodingHelper<_Ty,-1>{
    typedef _Ty&                rtype;
    typedef const _Ty&          ctype;
    inline static int32_t Encode(int32_t field, ctype val, int32_t count, uint8_t* buf, uint32_t len) {
        return EncodeField(field, &val, -1, buf, len);
    }
    inline static int32_t Decode(int32_t* field, rtype des, int32_t* count, const uint8_t* buf, uint32_t len) {
        return DecodeField(field, &des, NULL, buf, len);
    }
};


#endif//__HXNET_CODING_PLUSPLUS_H__