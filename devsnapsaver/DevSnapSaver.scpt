FasdUAS 1.101.10   ��   ��    k             l     ��  ��    T N =============================================================================     � 	 	 �   = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =   
  
 l     ��  ��    B < @file    snapshot-safari-to-devonthink-using-paparazzi.scpt     �   x   @ f i l e         s n a p s h o t - s a f a r i - t o - d e v o n t h i n k - u s i n g - p a p a r a z z i . s c p t      l     ��  ��    J D @brief   Import a full-page PDF version of a web page to DEVONthink     �   �   @ b r i e f       I m p o r t   a   f u l l - p a g e   P D F   v e r s i o n   o f   a   w e b   p a g e   t o   D E V O N t h i n k      l     ��  ��    2 , @author  Michael Hucka <mhucka@caltech.edu>     �   X   @ a u t h o r     M i c h a e l   H u c k a   < m h u c k a @ c a l t e c h . e d u >      l     ��  ��    H B @license Please see the file LICENSE.html in the parent directory     �   �   @ l i c e n s e   P l e a s e   s e e   t h e   f i l e   L I C E N S E . h t m l   i n   t h e   p a r e n t   d i r e c t o r y      l     ��   !��     T N =============================================================================    ! � " " �   = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =   # $ # l     �� % &��   %       & � ' '    $  ( ) ( l     �� * +��   * T N DEVONthink has a web import facility that is already able to create full-page    + � , , �   D E V O N t h i n k   h a s   a   w e b   i m p o r t   f a c i l i t y   t h a t   i s   a l r e a d y   a b l e   t o   c r e a t e   f u l l - p a g e )  - . - l     �� / 0��   / Q K snapshots of web pages in PDF format.  However, in my experience, it often    0 � 1 1 �   s n a p s h o t s   o f   w e b   p a g e s   i n   P D F   f o r m a t .     H o w e v e r ,   i n   m y   e x p e r i e n c e ,   i t   o f t e n .  2 3 2 l     �� 4 5��   4 S M fails to work for long pages (in which case, it produces a blank PDF).  I've    5 � 6 6 �   f a i l s   t o   w o r k   f o r   l o n g   p a g e s   ( i n   w h i c h   c a s e ,   i t   p r o d u c e s   a   b l a n k   P D F ) .     I ' v e 3  7 8 7 l     �� 9 :��   9 , & found Paparazzi! to be more reliable.    : � ; ; L   f o u n d   P a p a r a z z i !   t o   b e   m o r e   r e l i a b l e . 8  < = < l     ��������  ��  ��   =  > ? > l     �� @ A��   @ R L Unfortunately, the use of DEVONthink's import command via AppleScript loses    A � B B �   U n f o r t u n a t e l y ,   t h e   u s e   o f   D E V O N t h i n k ' s   i m p o r t   c o m m a n d   v i a   A p p l e S c r i p t   l o s e s ?  C D C l     �� E F��   E P J some of the nice features of its native web clipper facility, such as the    F � G G �   s o m e   o f   t h e   n i c e   f e a t u r e s   o f   i t s   n a t i v e   w e b   c l i p p e r   f a c i l i t y ,   s u c h   a s   t h e D  H I H l     �� J K��   J 6 0 list of recently used Groups.  It's a tradeoff.    K � L L `   l i s t   o f   r e c e n t l y   u s e d   G r o u p s .     I t ' s   a   t r a d e o f f . I  M N M l     ��������  ��  ��   N  O P O l     Q���� Q r      R S R m      T T � U U 
 1 . 1 . 0 S o      ���� 0 versionnumber versionNumber��  ��   P  V W V l     ��������  ��  ��   W  X Y X l     �� Z [��   Z &   Global variables and constants.    [ � \ \ @   G l o b a l   v a r i a b l e s   a n d   c o n s t a n t s . Y  ] ^ ] l     �� _ `��   _ S M ............................................................................    ` � a a �   . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ^  b c b l     ��������  ��  ��   c  d e d p       f f ������ 0 thetitle theTitle��   e  g h g p       i i ������ 0 theurl theURL��   h  j k j p       l l ������ "0 destinationfile destinationFile��   k  m n m l     ��������  ��  ��   n  o p o l    q���� q r     r s r m     t t � u u & / t m p / _ p a p a r a z z i . p d f s o      ���� "0 destinationfile destinationFile��  ��   p  v w v l     ��������  ��  ��   w  x y x l     �� z {��   z   Utility functions.    { � | | &   U t i l i t y   f u n c t i o n s . y  } ~ } l     ��  ���    S M ............................................................................    � � � � �   . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ~  � � � l     ��������  ��  ��   �  � � � i      � � � I      �������� 0 devonthink_import  ��  ��   � O     � � � � k    � � �  � � � I   ������
�� .miscactvnull��� ��� null��  ��   �  � � � r     � � � I   �� � �
�� .DTpacd01DTrc       utxt � o    ���� "0 destinationfile destinationFile � �� ���
�� 
pnam � o    ���� 0 thetitle theTitle��   � o      ���� 0 
thisrecord 
thisRecord �  � � � Z    E � ��� � � I   �� ���
�� .coredoexbool       obj  � o    ���� 0 
thisrecord 
thisRecord��   � O     ; � � � k   $ : � �  � � � r   $ ) � � � o   $ %���� 0 theurl theURL � 1   % (��
�� 
pURL �  � � � r   * 2 � � � J   * . � �  � � � m   * + � � � � �  f r o m - S a f a r i �  ��� � m   + , � � � � �  a r c h i v e d - p a g e��   � 1   . 1��
�� 
tags �  ��� � r   3 : � � � l  3 8 ����� � n   3 8 � � � 1   6 8��
�� 
DTcg � l  3 6 ����� � n   3 6 � � � m   4 6��
�� 
DTkb � o   3 4���� 0 
thisrecord 
thisRecord��  ��  ��  ��   � o      ���� 0 	thisgroup 	thisGroup��   � o     !���� 0 
thisrecord 
thisRecord��   � r   > E � � � l  > C ����� � 1   > C��
�� 
DTig��  ��   � o      ���� 0 	thisgroup 	thisGroup �  � � � r   F Q � � � c   F O � � � l  F K ����� � n   F K � � � 1   G K��
�� 
rURL � o   F G���� 0 
thisrecord 
thisRecord��  ��   � m   K N��
�� 
TEXT � o      ���� 0 refurl refURL �  � � � r   R ] � � � I  R [�� � �
�� .DTpacd77DTrc       utxt � o   R S���� 0 theurl theURL � �� ���
�� 
DTin � o   V W���� 0 	thisgroup 	thisGroup��   � o      ���� 0 thisarchive thisArchive �  � � � Z   ^ � � ����� � I  ^ c�� ���
�� .coredoexbool       obj  � o   ^ _���� 0 thisarchive thisArchive��   � O   f � � � � k   j � � �  � � � r   j o � � � o   j k���� 0 theurl theURL � 1   k n��
�� 
pURL �  � � � r   p | � � � J   p x � �  � � � m   p s � � � � �  f r o m - S a f a r i �  ��� � m   s v � � � � �  a r c h i v e d - p a g e��   � 1   x {��
�� 
tags �  ��� � r   } � � � � b   } � � � � m   } � � � � � � R P D F   o f   t h i s   p a g e   a r c h i v e d   i n   D E V O N t h i n k :   � o   � ����� 0 refurl refURL � 1   � ���
�� 
DTco��   � o   f g���� 0 thisarchive thisArchive��  ��   �  � � � r   � � � � � c   � � � � � l  � � ����� � n   � � � � � 1   � ���
�� 
rURL � o   � ����� 0 thisarchive thisArchive��  ��   � m   � ���
�� 
TEXT � o      ���� 0 archiverefurl archiveRefURL �  � � � Z   � � � ����� � I  � ��� ���
�� .coredoexbool       obj  � o   � ����� 0 
thisrecord 
thisRecord��   � O   � � � � � r   � � � � � b   � � � � � m   � � � � � � � b W e b   a r c h i v e   o f   t h i s   p a g e   a r c h i v e d   i n   D E V O N t h i n k :   � o   � ����� 0 archiverefurl archiveRefURL � 1   � ���
�� 
DTco � o   � ����� 0 
thisrecord 
thisRecord��  ��   �  ��� � I  � ��� ���
�� .JonspClpnull���     **** � o   � ��� 0 refurl refURL��  ��   � 5     �~ �}
�~ 
capp  m     �  D N t p
�} kfrmID   �  l     �|�{�z�|  �{  �z    l     �y�y     Main body.    �		    M a i n   b o d y . 

 l     �x�x   S M ............................................................................    � �   . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .  l     �w�v�u�w  �v  �u    l     �t�t   @ : Test if Paparazzi! is installed and complain if it isn't.    � t   T e s t   i f   P a p a r a z z i !   i s   i n s t a l l e d   a n d   c o m p l a i n   i f   i t   i s n ' t .  l     �s�r�q�s  �r  �q    l   (�p�o Q    ( O     e       n    !"! 1    �n
�n 
pnam" 5    �m#�l
�m 
appf# m    $$ �%% , o r g . d e r a i l e r . P a p a r a z z i
�l kfrmID   m    &&�                                                                                  MACS  alis    f  clarity                    ԛn}H+     (
Finder.app                                                      �1�GЎ        ����  	                CoreServices    ԛ��      �HA       (   '   &  1clarity:System: Library: CoreServices: Finder.app    
 F i n d e r . a p p    c l a r i t y  &System/Library/CoreServices/Finder.app  / ��   R      �k�j�i
�k .ascrerr ****      � ****�j  �i   k     ('' ()( I    %�h*�g
�h .sysodlogaskr        TEXT* m     !++ �,, b C o u l d   n o t   f i n d   a p p l i c a t i o n   P a p a r a z z i !      q u i t t i n g .�g  ) -�f- L   & (.. m   & '�e�e �f  �p  �o   /0/ l     �d�c�b�d  �c  �b  0 121 l     �a34�a  3   Good so far.  Proceed.   4 �55 .   G o o d   s o   f a r .     P r o c e e d .2 676 l     �`�_�^�`  �_  �^  7 898 l  ) K:�]�\: O   ) K;<; k   - J== >?> r   - :@A@ e   - 6BB n   - 6CDC 1   3 5�[
�[ 
pnamD l  - 3E�Z�YE n   - 3FGF 1   1 3�X
�X 
cTabG l  - 1H�W�VH 4  - 1�UI
�U 
cwinI m   / 0�T�T �W  �V  �Z  �Y  A o      �S�S 0 thetitle theTitle? J�RJ r   ; JKLK e   ; FMM n   ; FNON 1   A E�Q
�Q 
pURLO l  ; AP�P�OP n   ; AQRQ 1   ? A�N
�N 
cTabR l  ; ?S�M�LS 4  ; ?�KT
�K 
cwinT m   = >�J�J �M  �L  �P  �O  L o      �I�I 0 theurl theURL�R  < m   ) *UU�                                                                                  sfri  alis    >  clarity                    ԛn}H+     G
Safari.app                                                     �@.Ӛ��        ����  	                Applications    ԛ��      ӛJ=       G   clarity:Applications: Safari.app   
 S a f a r i . a p p    c l a r i t y  Applications/Safari.app   / ��  �]  �\  9 VWV l     �H�G�F�H  �G  �F  W XYX l  L rZ�E�DZ Q   L r[\][ e   O R^^ o   O R�C�C 0 theurl theURL\ R      �B�A�@
�B .ascrerr ****      � ****�A  �@  ] k   Z r__ `a` I  Z o�?bc
�? .sysodlogaskr        TEXTb m   Z ]dd �ee < C o u l d   n o t   o b t a i n   w e b   p a g e   U R L .c �>fg
�> 
btnsf J   ` ehh i�=i m   ` cjj �kk  O K�=  g �<l�;
�< 
displ m   h i�:�: �;  a m�9m L   p rnn m   p q�8�8 �9  �E  �D  Y opo l     �7�6�5�7  �6  �5  p qrq l  s �s�4�3s O   s �tut Z   y �vw�2�1v I  y ��0x�/
�0 .coredoexbool       obj x 4   y �.y
�. 
filey o   } ~�-�- "0 destinationfile destinationFile�/  w O  � �z{z I  � ��,|�+
�, .coredelonull���     obj | c   � �}~} o   � ��*�* "0 destinationfile destinationFile~ m   � ��)
�) 
psxf�+  { m   � ��                                                                                  MACS  alis    f  clarity                    ԛn}H+     (
Finder.app                                                      �1�GЎ        ����  	                CoreServices    ԛ��      �HA       (   '   &  1clarity:System: Library: CoreServices: Finder.app    
 F i n d e r . a p p    c l a r i t y  &System/Library/CoreServices/Finder.app  / ��  �2  �1  u m   s v���                                                                                  sevs  alis    �  clarity                    ԛn}H+     (System Events.app                                               ������        ����  	                CoreServices    ԛ��      ��#(       (   '   &  8clarity:System: Library: CoreServices: System Events.app  $  S y s t e m   E v e n t s . a p p    c l a r i t y  -System/Library/CoreServices/System Events.app   / ��  �4  �3  r ��� l     �(�'�&�(  �'  �&  � ��� l  ���%�$� O   ���� k   �
�� ��� I  � ��#�"�!
�# .miscactvnull��� ��� null�"  �!  � ��� I  � �� ��
�  .Pzi!Captnull���     ctxt� o   � ��� 0 theurl theURL� ���
� 
cDly� m   � ��� �  � ��� l  � �����  �  �  � ��� r   � ���� m   � ��
� boovtrue� o      �� $0 togglevisibility toggleVisibility� ��� V   � ���� k   � ��� ��� l  � �����  � 9 3 Wait until Paparazzi! finishes capturing the page.   � ��� f   W a i t   u n t i l   P a p a r a z z i !   f i n i s h e s   c a p t u r i n g   t h e   p a g e .� ��� l  � �����  � E ? NB: if I put this visibility code outside the loop, Paparazzi    � ��� ~   N B :   i f   I   p u t   t h i s   v i s i b i l i t y   c o d e   o u t s i d e   t h e   l o o p ,   P a p a r a z z i  � ��� l  � �����  � ( " doesn't hide after being invoked.   � ��� D   d o e s n ' t   h i d e   a f t e r   b e i n g   i n v o k e d .� ��� Z   � ������ o   � ��� $0 togglevisibility toggleVisibility� k   � ��� ��� O   � ���� r   � ���� m   � ��
� boovfals� n      ��� 1   � ��
� 
pvis� 4   � ���
� 
pcap� m   � ��� ���  P a p a r a z z i !� m   � ����                                                                                  sevs  alis    �  clarity                    ԛn}H+     (System Events.app                                               ������        ����  	                CoreServices    ԛ��      ��#(       (   '   &  8clarity:System: Library: CoreServices: System Events.app  $  S y s t e m   E v e n t s . a p p    c l a r i t y  -System/Library/CoreServices/System Events.app   / ��  � ��� r   � ���� m   � ��
� boovfals� o      �
�
 $0 togglevisibility toggleVisibility�  �  �  �  � 1   � ��	
�	 
pBzy� ��� I  ����
� .coresavenull���     obj �  � ���
� 
fltp� m   � ��
� sFMTPDF � ���
� 
kfil� o   � ��� "0 destinationfile destinationFile�  � ��� I 
� ���
�  .coreclosnull���     obj � 4 ���
�� 
cwin� m  ���� ��  �  � m   � ����                                                                                  Pzi!  alis    N  clarity                    ԛn}H+     GPaparazzi!.app                                                 s��iY�        ����  	                Applications    ԛ��      �i�X       G  $clarity:Applications: Paparazzi!.app    P a p a r a z z i ! . a p p    c l a r i t y  Applications/Paparazzi!.app   / ��  �%  �$  � ��� l     ��������  ��  ��  � ��� l \������ O  \��� Z  [������ I �����
�� .coredoexbool       obj � 4  ���
�� 
file� o  ���� "0 destinationfile destinationFile��  � k  I�� ��� n $��� I   $�������� 0 devonthink_import  ��  ��  �  f   � ��� O %3��� I )2�����
�� .coredelonull���     obj � c  ).��� o  )*���� "0 destinationfile destinationFile� m  *-��
�� 
psxf��  � m  %&���                                                                                  MACS  alis    f  clarity                    ԛn}H+     (
Finder.app                                                      �1�GЎ        ����  	                CoreServices    ԛ��      �HA       (   '   &  1clarity:System: Library: CoreServices: Finder.app    
 F i n d e r . a p p    c l a r i t y  &System/Library/CoreServices/Finder.app  / ��  � ���� I 4I����
�� .sysonotfnull��� ��� TEXT� o  47���� 0 theurl theURL� ����
�� 
appr� m  :=�� ��� & S a v e d   t o   D E V O N t h i n k� �����
�� 
subt� o  @C���� 0 thetitle theTitle��  ��  ��  � k  L[�� ��� I LS�����
�� .sysodisAaleR        TEXT� m  LO�� ��� B P a p a r a z z i   f a i l e d   t o   s a v e   t h e   f i l e��  � ���� I T[�����
�� .miscactvnull��� ��� null� m  TW���                                                                                  Pzi!  alis    N  clarity                    ԛn}H+     GPaparazzi!.app                                                 s��iY�        ����  	                Applications    ԛ��      �i�X       G  $clarity:Applications: Paparazzi!.app    P a p a r a z z i ! . a p p    c l a r i t y  Applications/Paparazzi!.app   / ��  ��  ��  � m  ���                                                                                  sevs  alis    �  clarity                    ԛn}H+     (System Events.app                                               ������        ����  	                CoreServices    ԛ��      ��#(       (   '   &  8clarity:System: Library: CoreServices: System Events.app  $  S y s t e m   E v e n t s . a p p    c l a r i t y  -System/Library/CoreServices/System Events.app   / ��  ��  ��  � ��� l     ��������  ��  ��  � ���� l     ��������  ��  ��  ��       
����� T t��������  � ������������������ 0 devonthink_import  
�� .aevtoappnull  �   � ****�� 0 versionnumber versionNumber�� "0 destinationfile destinationFile�� 0 thetitle theTitle�� 0 theurl theURL�� $0 togglevisibility toggleVisibility��  � �� ����������� 0 devonthink_import  ��  ��  � ������������ 0 
thisrecord 
thisRecord�� 0 	thisgroup 	thisGroup�� 0 refurl refURL�� 0 thisarchive thisArchive�� 0 archiverefurl archiveRefURL� �������������������� � ����������������� � � ��� ���
�� 
capp
�� kfrmID  
�� .miscactvnull��� ��� null�� "0 destinationfile destinationFile
�� 
pnam�� 0 thetitle theTitle
�� .DTpacd01DTrc       utxt
�� .coredoexbool       obj �� 0 theurl theURL
�� 
pURL
�� 
tags
�� 
DTkb
�� 
DTcg
�� 
DTig
�� 
rURL
�� 
TEXT
�� 
DTin
�� .DTpacd77DTrc       utxt
�� 
DTco
�� .JonspClpnull���     ****�� �)���0 �*j O���l E�O�j   � �*�,FO��lv*�,FO��,�,E�UY 	*a ,E�O�a ,a &E�O�a �l E�O�j  (�  �*�,FOa a lv*�,FOa �%*a ,FUY hO�a ,a &E�O�j  � a �%*a ,FUY hO�j U� �����������
�� .aevtoappnull  �   � ****� k    \��  O    o  8 X q � �����  ��  ��  �  � 3 T�� t��&��$��������+��U����������d��j������������������������������������������������������� 0 versionnumber versionNumber�� "0 destinationfile destinationFile
�� 
appf
�� kfrmID  
�� 
pnam��  ��  
�� .sysodlogaskr        TEXT
�� 
cwin
�� 
cTab�� 0 thetitle theTitle
�� 
pURL�� 0 theurl theURL
�� 
btns
�� 
disp�� 
�� 
file
�� .coredoexbool       obj 
�� 
psxf
�� .coredelonull���     obj 
�� .miscactvnull��� ��� null
�� 
cDly�� 
�� .Pzi!Captnull���     ctxt�� $0 togglevisibility toggleVisibility
�� 
pBzy
�� 
pcap
�� 
pvis
�� 
fltp
�� sFMTPDF 
�� 
kfil
�� .coresavenull���     obj 
�� .coreclosnull���     obj �� 0 devonthink_import  
�� 
appr
�� 
subt
�� .sysonotfnull��� ��� TEXT
�� .sysodisAaleR        TEXT��]�E�O�E�O � 
*���0�,EUW X 	 
�j OkO� *�k/�,�,EE` O*�k/�,a ,EE` UO _ W X 	 
a a a kva la  OkOa  !*a �/j  � �a &j UY hUOa  l*j O_ a a  l !OeE` "O 4h*a #,E_ "  a  f*a $a %/a &,FUOfE` "Y h[OY��O*a 'a (a )�a  *O*�k/j +UOa  K*a �/j  /)j+ ,O� �a &j UO_ a -a .a /_ a  0Y a 1j 2Oa j U� � @ H o m e   �   c a s i c s / r e p o - t e m p l a t e   W i k i� � X h t t p s : / / g i t h u b . c o m / c a s i c s / r e p o - t e m p l a t e / w i k i
�� boovfals��  ascr  ��ޭ