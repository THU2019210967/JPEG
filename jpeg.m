I = imread('cameraman.tif'); 
info=imfinfo('cameraman.tif');
%ԭʼͼ��ΪRGBͼ��תΪ�Ҷ�ͼ
A=double(I);
%��dct�任��Ҫ��ͼ��תΪ˫���ȣ����ѵ�ƽƽ��128����λ
I=double(I)-128;
%I=im2double(I);
[H,L]=size(I);
%8X8dct�任;DCTIΪͼ������DCT�任�����
T=dctmtx(8);%����һ��8*8 DCT�任����

%DCTI=blkproc(I,[8 8],'dct2');
DCTI=blkproc(I,[8,8],'P1*x*P2',T,T');% x����ÿһ���ֳɵ�8*8��С�Ŀ飬P1*x*P2�൱�����ؿ�Ĵ�������p1=T p2=T',Ҳ����fun=p1*x*p2'=T*x*T'�Ĺ����ǽ�����ɢ���ұ任 B=T*I*T��

%������������,roΪ������������
ro=[16 11 10 16 24 40 51 61
    12 12 14 19 26 58 60 55
    14 13 16 24 40 57 69 56
    14 17 22 29 51 87 80 62
    18 22 37 56 68 109 103 77
    24 35 55 64 81 104 113 92
    49 64 78 87 103 121 120 101
    72 92 95 98 112 100 103 99];
 
%8X8������DCTI1ΪDCTI����������
DCTI1=blkproc(DCTI,[8 8],'round(x./P1)',ro);

DCTI2=[];
DCTI2=DCTI1;
 
%�ֳ�8*8�Ŀ飬�Ա���ȡDCϵ��
i=0;
for h=1:H/8
    for l=1:L/8
        i=i+1;
        block88(:,:,i)=DCTI1(((h-1)*8+1):((h-1)*8+8),((l-1)*8+1):((l-1)*8+8));
    end
end
 
%��ȡֱ��ϵ����DC����
for i=1:H*L/64
    DC(:,:,i)=block88(1,1,i);
end
 
%DC�������õ�ǰDC-ǰһ��DCϵ�����統ǰϵ��Ϊ15ǰһ��DCϵ��Ϊ12����ѵ���������DC1��
  DC1(:,:,1)=DC(:,:,1);
for i=2:H*L/64
    DC1(:,:,i)=DC(:,:,i)-DC(:,:,i-1);
end
 
%��DC1�������������,DCTI1��ʱ��DCϵ���滻��ľ���
h=H/8;
l=L/8;
k=0;
for i=1:h
    for j=1:l
        k=k+1;
        DCTI1(1+(i-1)*8,1+(j-1)*8)=DC1(:,:,k);
    end
end
k;    
 
%����
       ImageSeq=[];
       ImageLen=[]; 
       FFFF=[];
for r=1:H/8
    for c=1:L/8
        
        %�ѿ�������zigzag����
        m(1:8,1:8)=DCTI1((r-1)*8+1:(r-1)*8+8,(c-1)*8+1:(c-1)*8+8);
        k1=zigzag(m);
        
        %�ҳ����һλ��Ϊ0��zigzag������±�
        w=0;
        u=64;
        while u ~= 0
             if k1(u) ~= 0
                w=u;
                break;
             end
             u=u-1;
       end
       w;
       
       %63��ϵ��ȫΪ0���������w=0�޷����룬���԰Ѿ����±긳ֵΪ1
       if w==0 
          w=1;
       end
       
       %wΪ���һ����Ϊ0��ϵ�����±꣬eΪzigzagɨ����tȥ��ĩβ��0��õ���һά������
       e(w)=0;
       for i=1:w
           e(i)=k1(i);
       end
 
       %��DCϵ������Huffman����
       [DC_seq,DC_len]=DCEncoding(e(1));
       DC_seq;
       DC_len;
    %   FFFF(r+c,1)=DC_seq;
      FFFF(r+c,2)=DC_len;
       
 
       %zerolenΪ��0����0�ĸ�����amplitudeΪ��0�����0ֵ�ķ��ȣ�end=1010(�������EOB
       end_seq=dec2bin(10,4);
       AC_seq=[];
       blockbit_seq=[];
       zrl_seq=[];
       trt_seq=[];
       zerolen=0;
       zeronumber=0;
              
        %�ֿ���ֻ�е�һ��DCϵ��Ϊ0��Ϊ0��ACϵ��ȫΪ0�����
       if numel(e)==1
          AC_seq=[];
          blockbit_seq=[DC_seq,end_seq];
          blockbit_len=length(blockbit_seq);
       else 
          for i=2:w
              if ( e(i)==0 & zeronumber<16)
                  zeronumber=zeronumber+1;
                  %16����0�ı�ʾ
              elseif (e(i)==0 & zeronumber==16); 
                  bit_seq=dec2bin(2041,11);
                  zeronumber=1;
                  AC_seq=[AC_seq,bit_seq];
              elseif (e(i)~=0 & zeronumber==16)
                  zrl_seq=dec2bin(2041,11);
                  amplitude=e(i);
                  trt_seq=ACEncoding(0,amplitude);
                  bit_seq=[zrl_seq,trt_seq];
                  AC_seq=[AC_seq,bit_seq];
                  zeronumber=0;
              elseif(e(i))
                  zerolen=zeronumber;          
                  amplitude=e(i); 
                  zeronumber=0;
                  bit_seq=ACEncoding(zerolen,amplitude);
                  AC_seq=[AC_seq,bit_seq];
              end
          end
       end                 
       blockbit_seq=[DC_seq,AC_seq,end_seq];
       blockbit_len=length(blockbit_seq);
 
       %blockbit_seqΪ������ı������У�blockbit_lenΪ������ı��볤��
       blockbit_seq;
       blockbit_len;
       ImageSeq=[ImageSeq,blockbit_seq];
       ImageLen=numel(ImageSeq);       
    end
end
    
 
%�ָ�ͼ��
Q=blkproc(DCTI2,[8,8],'x.*P1',ro);
 
Recover=blkproc(Q,[8,8],'idct2(x)');
RecoverImage=round(Recover)+128;
 
RecoverImage=uint8(RecoverImage);
imwrite(RecoverImage,'new.jpeg');

imshow(RecoverImage); 