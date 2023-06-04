.text
# 内存分配情况
# 0~128 小车显示
# 128~256 金币显示
# 256~512 预留
# 512~1536 地图加载1
# 1536~2560 地图加载1
# 1986~2044 堆栈
# s0：32位二进制数中,为1的位表示飞机
# s1: 32位二进制数中,为1的位表示飞机
# s2: 32位二进制数中,为1的位表示飞机
# s3: 32位二进制数中,为1的位表示飞机
# s4: 32位二进制数中,为1的位表示飞机
# s5：飞机所处的行数等于 s5/4
# s6: 表示飞机的位置
# s7,s8: 中间变量, 当作全局变量用的,只能在主函数中使用,不要再中断中使用
# t0~t5 碰撞检查,现在只在中断中使用
# t6=16 中间变量,当作局部变量使用的,在中断中使用
# a7,系统调用,被调用者保护
# 34显示金币,35显示飞机,36扣分,37调用检查碰撞中断,90金币堆栈全体位移,100边界
# ra, 游戏是否开始, ra =0表示没有开始, ra =1标识开始
# a0~a6 用来生成金币
# gp 基址寄存器 512
# sp 堆栈 ,初始为 3068
# tp 表示碰撞检查是否结束

    beq zero,zero, main_function
# 中断,控制游戏开始
game_start:
    bne ra, zero, not_first #555555555555555555555
    addi ra, zero, 1
    not_first:
    uret

# 中断,飞机右移
interrupt_right:

    sw a7, 0(sp)             # 保存现场222222222222222222222

    beq ra, zero, not_start1 #

    addi t6,zero,108
    beq s5, t6, border       # 判断走到边界

    addi s5, s5, 4           # 下移飞机
    sw zero, -12(s5)
    sw s0, -8(s5)
    sw s1, -4(s5)
    sw s2,  0(s5)
    sw s3,  4(s5)
    sw s4,  8(s5)

    addi a7, zero, 35    
    ecall                    # 调用系统功能,显示飞机

    not_start1:
    lw a7, 0(sp)             # 恢复现场

    uret

# 中断,控制飞机左移
interrupt_left:

    sw a7, 0(sp)             # 保存现场1111111111111111111
                            #
    beq ra, zero, not_start2 # 游戏开始才能动

    addi t6, zero,16
    beq s5, t6, border # 走到边界
    addi s5, s5, -4

    sw zero, 12(s5)
    sw s0, -8(s5)
    sw s1, -4(s5)
    sw s2,  0(s5)
    sw s3,  4(s5)
    sw s4,  8(s5)
    addi a7, zero, 35  
    ecall

    not_start2:
    lw a7, 0(sp)             # 恢复现场
    uret

# 中断,飞机上移
interrupt_up:
    sw a7, 0(sp)             # 保存现场33333333333333333
    beq ra, zero, not_start3 #

    addi t6,zero,27          # 走到边界
    beq s6, t6, border

    addi s6, s6, 1
    srli s0, s0, 1           # 移动飞机
    srli s1, s1, 1
    srli s2, s2, 1
    srli s3, s3, 1
    srli s4, s4, 1
    sw s0, -8(s5)
    sw s1, -4(s5)
    sw s2,  0(s5)
    sw s3,  4(s5)
    sw s4,  8(s5)
    addi a7, zero, 35  
    ecall

    not_start3:              # 游戏未开始
    lw a7, 0(sp)             # 恢复现场
    uret

# 中断,飞机下移
interrupt_down:
    sw a7, 0(sp)             # 保存现场4444444444444
    beq ra, zero, not_start4 #
        
    beq s6, zero, border     # 走到边界

    addi s6, s6, -1
    slli s0, s0, 1           # 移动飞机
    slli s1, s1, 1
    slli s2, s2, 1
    slli s3, s3, 1
    slli s4, s4, 1
    sw s0, -8(s5)
    sw s1, -4(s5)
    sw s2,  0(s5)
    sw s3,  4(s5)
    sw s4,  8(s5)
    addi a7, zero, 35  
    ecall

    not_start4:              # 游戏未开始
    lw a7, 0(sp)             # 恢复现场
    uret

    #边界,发出警告
    border: 
    addi a7, zero, 100 
    ecall
    lw a7, 0(sp)             # 恢复现场
    uret

#中断,检查碰撞
interrupt_check:   
    sw a7, 0(sp)     # 6666666666666666
    lw t0, 120(s5)       
    lw t1, 124(s5)
    lw t2, 128(s5)
    lw t3, 132(s5)
    lw t4, 136(s5)

    and t5, t0, s0
    beq t5, zero, check00
    addi a7, zero, 36
    ecall 
    xori t5, s0, -1
    and t0, t0, t5
    sw t0, 120(s5)

    check00:
    and t5, t1, s1
    beq t5, zero, check01
    addi a7, zero, 36
    ecall 
    xori t5, s1, -1
    and t1, t1, t5
    sw t1, 124(s5)

    check01:
    and t5, t2, s2
    beq t5, zero, check02
    addi a7, zero, 36
    ecall 
    xori t5, s2, -1
    and t2, t2, t5
    sw t2, 128(s5)

    check02:
    and t5, t3, s3
    beq t5, zero, check03
    addi a7, zero, 36
    ecall 
    xori t5, s3, -1
    and t3, t3, t5
    sw t3, 132(s5)

    check03:
    and t5, t4, s4
    beq t5, zero, check04
    addi a7, zero, 36
    ecall 
    xori t5, s4, -1
    and t4, t4, t5
    sw t4, 136(s5)

    check04:
    # 检查结束
    addi tp, zero, 1
    sw a7, 0(sp)
    uret

main_function:          
    addi sp, zero, 2044       # 初始化栈
    addi sp, zero, 1024
    addi ra, zero, 0         # 标识游戏未开始
    # 准备飞机的图案
    addi s0, zero, 0x020     #   o  
    addi s1, zero, 0x0b0     # o oo 
    addi s2, zero, 0x0f8     # ooooo
    addi s3, zero, 0x0b0     # o oo
    addi s4, zero, 0x020     #   0
    slli  s0, s0, 23     
    slli  s1, s1, 23 
    slli  s2, s2, 23 
    slli  s3, s3, 23 
    slli  s4, s4, 23 

    addi s5, zero, 64        # 初始X坐标
    addi s6, zero, 1         # 初始Y坐标
    #道路布局
    addi s7, zero, -1 

    #初始化边缘
    sw s7, 0(zero)  
    sw s7, 4(zero)
    sw s7, 120(zero)
    sw s7, 124(zero)
    #清空地图
    sw zero, 8(zero)
    sw zero, 12(zero)
    sw zero, 16(zero)
    sw zero, 20(zero)
    sw zero, 24(zero)
    sw zero, 28(zero)
    sw zero, 32(zero)
    sw zero, 36(zero)
    sw zero, 40(zero)
    sw zero, 44(zero)
    sw zero, 48(zero)
    sw zero, 52(zero)
    sw zero, 56(zero)
    sw zero, 60(zero)
    sw zero, 68(zero)
    sw zero, 72(zero)
    sw zero, 76(zero)
    sw zero, 80(zero)
    sw zero, 84(zero)
    sw zero, 88(zero)
    sw zero, 92(zero)
    sw zero, 96(zero)
    sw zero, 100(zero)
    sw zero, 104(zero)
    sw zero, 108(zero)
    sw zero, 112(zero)
    sw zero, 116(zero)

    addi s7, zero, 128
    sw zero, 0(s7)
    sw zero, 4(s7)
    sw zero, 8(s7)
    sw zero, 12(s7)
    sw zero, 16(s7)
    sw zero, 20(s7)
    sw zero, 24(s7)
    sw zero, 28(s7)
    sw zero, 32(s7)
    sw zero, 36(s7)
    sw zero, 40(s7)
    sw zero, 44(s7)
    sw zero, 48(s7)
    sw zero, 52(s7)
    sw zero, 56(s7)
    sw zero, 60(s7)
    sw zero, 68(s7)
    sw zero, 72(s7)
    sw zero, 76(s7)
    sw zero, 80(s7)
    sw zero, 84(s7)
    sw zero, 88(s7)
    sw zero, 92(s7)
    sw zero, 96(s7)
    sw zero, 100(s7)
    sw zero, 104(s7)
    sw zero, 108(s7)
    sw zero, 112(s7)
    sw zero, 116(s7)
    sw zero, 120(s7)
    sw zero, 124(s7)

# 初始化金币地图,地图保存在RAM中,加载地图的时候读出
# 数据结构
# struct {
#     int col_number;     // col_number = 金币生成的列号 * 4 ,取值范围是[8,116]    
#     int is_golden;      // 是否有金币,为0表示没有金币,为1表示有金币
# }map[128];              //map的初始地址为512, 结束地址1536(用a6寄存器控制)
# 生成地图逻辑
# for(int i = 0;i<128;i++){
#     //如果没有金币,
#     if(map[i].is_golden){
#         在(col_number/4)那列加一个金币;
#     }
#     所有金币向下移动一格;      
# }
# 示例
# addi, a0, zero, col_number
# addi, a1, zero, is_golden
# sw a0, addr(zero)
# sw a1, addr(a2) 
# is_golden=0的那段可以省略,只用写is_golden=1 的那些段
    addi gp, zero, 512       # 初始化基址寄存器,gp相当于首地址    
    addi a2, gp, 4          # 初始化基址寄存器
addi a0, zero, 64
addi a1, zero, 1
sw a0, 0(gp)
sw a1, 0(a2)

addi a0, zero, 80
addi a1, zero, 1
sw a0, 8(gp)
sw a1, 8(a2)

addi a0, zero, 24
addi a1, zero, 1
sw a0, 32(gp)
sw a1, 32(a2)

addi a0, zero, 36
addi a1, zero, 1
sw a0, 48(gp)
sw a1, 48(a2)

addi a0, zero, 52
addi a1, zero, 1
sw a0, 64(gp)
sw a1, 64(a2)

addi a0, zero, 12
addi a1, zero, 1
sw a0, 88(gp)
sw a1, 88(a2)

addi a0, zero, 60
addi a1, zero, 1
sw a0, 112(gp)
sw a1, 112(a2)

addi a0, zero, 12
addi a1, zero, 1
sw a0, 120(gp)
sw a1, 120(a2)

addi a0, zero, 16
addi a1, zero, 1
sw a0, 136(gp)
sw a1, 136(a2)

addi a0, zero, 12
addi a1, zero, 1
sw a0, 152(gp)
sw a1, 152(a2)

addi a0, zero, 116
addi a1, zero, 1
sw a0, 160(gp)
sw a1, 160(a2)

addi a0, zero, 76
addi a1, zero, 1
sw a0, 216(gp)
sw a1, 216(a2)

addi a0, zero, 12
addi a1, zero, 1
sw a0, 240(gp)
sw a1, 240(a2)

addi a0, zero, 64
addi a1, zero, 1
sw a0, 256(gp)
sw a1, 256(a2)

addi a0, zero, 76
addi a1, zero, 1
sw a0, 288(gp)
sw a1, 288(a2)

addi a0, zero, 108
addi a1, zero, 1
sw a0, 352(gp)
sw a1, 352(a2)

addi a0, zero, 8
addi a1, zero, 1
sw a0, 360(gp)
sw a1, 360(a2)

addi a0, zero, 48
addi a1, zero, 1
sw a0, 368(gp)
sw a1, 368(a2)

addi a0, zero, 36
addi a1, zero, 1
sw a0, 384(gp)
sw a1, 384(a2)

addi a0, zero, 72
addi a1, zero, 1
sw a0, 464(gp)
sw a1, 464(a2)

addi a0, zero, 12
addi a1, zero, 1
sw a0, 480(gp)
sw a1, 480(a2)

addi a0, zero, 32
addi a1, zero, 1
sw a0, 544(gp)
sw a1, 544(a2)

addi a0, zero, 44
addi a1, zero, 1
sw a0, 560(gp)
sw a1, 560(a2)

addi a0, zero, 76
addi a1, zero, 1
sw a0, 640(gp)
sw a1, 640(a2)

addi a0, zero, 16
addi a1, zero, 1
sw a0, 688(gp)
sw a1, 688(a2)

addi a0, zero, 20
addi a1, zero, 1
sw a0, 736(gp)
sw a1, 736(a2)

addi a0, zero, 100
addi a1, zero, 1
sw a0, 784(gp)
sw a1, 784(a2)

addi a0, zero, 60
addi a1, zero, 1
sw a0, 792(gp)
sw a1, 792(a2)

addi a0, zero, 80
addi a1, zero, 1
sw a0, 840(gp)
sw a1, 840(a2)

addi a0, zero, 104
addi a1, zero, 1
sw a0, 864(gp)
sw a1, 864(a2)

addi a0, zero, 84
addi a1, zero, 1
sw a0, 896(gp)
sw a1, 896(a2)

addi a0, zero, 68
addi a1, zero, 1
sw a0, 944(gp)
sw a1, 944(a2)

addi a0, zero, 92
addi a1, zero, 1
sw a0, 952(gp)
sw a1, 952(a2)

addi a0, zero, 28
addi a1, zero, 1
sw a0, 984(gp)
sw a1, 984(a2)
##########################################
addi gp, gp, 1024
addi a2, gp, 4
addi a0, zero, 100
addi a1, zero, 1
sw a0, 0(gp)
sw a1, 0(a2)

addi a0, zero, 112
addi a1, zero, 1
sw a0, 8(gp)
sw a1, 8(a2)

addi a0, zero, 92
addi a1, zero, 1
sw a0, 16(gp)
sw a1, 16(a2)

addi a0, zero, 100
addi a1, zero, 1
sw a0, 24(gp)
sw a1, 24(a2)

addi a0, zero, 44
addi a1, zero, 1
sw a0, 72(gp)
sw a1, 72(a2)

addi a0, zero, 48
addi a1, zero, 1
sw a0, 88(gp)
sw a1, 88(a2)

addi a0, zero, 64
addi a1, zero, 1
sw a0, 96(gp)
sw a1, 96(a2)

addi a0, zero, 116
addi a1, zero, 1
sw a0, 104(gp)
sw a1, 104(a2)

addi a0, zero, 104
addi a1, zero, 1
sw a0, 112(gp)
sw a1, 112(a2)

addi a0, zero, 60
addi a1, zero, 1
sw a0, 120(gp)
sw a1, 120(a2)

addi a0, zero, 12
addi a1, zero, 1
sw a0, 136(gp)
sw a1, 136(a2)

addi a0, zero, 104
addi a1, zero, 1
sw a0, 144(gp)
sw a1, 144(a2)

addi a0, zero, 44
addi a1, zero, 1
sw a0, 160(gp)
sw a1, 160(a2)

addi a0, zero, 32
addi a1, zero, 1
sw a0, 200(gp)
sw a1, 200(a2)

addi a0, zero, 80
addi a1, zero, 1
sw a0, 208(gp)
sw a1, 208(a2)

addi a0, zero, 100
addi a1, zero, 1
sw a0, 224(gp)
sw a1, 224(a2)

addi a0, zero, 36
addi a1, zero, 1
sw a0, 232(gp)
sw a1, 232(a2)

addi a0, zero, 100
addi a1, zero, 1
sw a0, 256(gp)
sw a1, 256(a2)

addi a0, zero, 100
addi a1, zero, 1
sw a0, 264(gp)
sw a1, 264(a2)

addi a0, zero, 104
addi a1, zero, 1
sw a0, 280(gp)
sw a1, 280(a2)

addi a0, zero, 8
addi a1, zero, 1
sw a0, 288(gp)
sw a1, 288(a2)

addi a0, zero, 76
addi a1, zero, 1
sw a0, 312(gp)
sw a1, 312(a2)

addi a0, zero, 48
addi a1, zero, 1
sw a0, 328(gp)
sw a1, 328(a2)

addi a0, zero, 12
addi a1, zero, 1
sw a0, 336(gp)
sw a1, 336(a2)

addi a0, zero, 60
addi a1, zero, 1
sw a0, 352(gp)
sw a1, 352(a2)

addi a0, zero, 56
addi a1, zero, 1
sw a0, 360(gp)
sw a1, 360(a2)

addi a0, zero, 16
addi a1, zero, 1
sw a0, 376(gp)
sw a1, 376(a2)

addi a0, zero, 112
addi a1, zero, 1
sw a0, 384(gp)
sw a1, 384(a2)

addi a0, zero, 96
addi a1, zero, 1
sw a0, 408(gp)
sw a1, 408(a2)

addi a0, zero, 80
addi a1, zero, 1
sw a0, 416(gp)
sw a1, 416(a2)

addi a0, zero, 64
addi a1, zero, 1
sw a0, 424(gp)
sw a1, 424(a2)

addi a0, zero, 56
addi a1, zero, 1
sw a0, 432(gp)
sw a1, 432(a2)

addi a0, zero, 24
addi a1, zero, 1
sw a0, 448(gp)
sw a1, 448(a2)

addi a0, zero, 76
addi a1, zero, 1
sw a0, 456(gp)
sw a1, 456(a2)

addi a0, zero, 20
addi a1, zero, 1
sw a0, 480(gp)
sw a1, 480(a2)

addi a0, zero, 88
addi a1, zero, 1
sw a0, 488(gp)
sw a1, 488(a2)

addi a0, zero, 40
addi a1, zero, 1
sw a0, 504(gp)
sw a1, 504(a2)

addi a0, zero, 80
addi a1, zero, 1
sw a0, 520(gp)
sw a1, 520(a2)

addi a0, zero, 92
addi a1, zero, 1
sw a0, 536(gp)
sw a1, 536(a2)

addi a0, zero, 36
addi a1, zero, 1
sw a0, 544(gp)
sw a1, 544(a2)

addi a0, zero, 48
addi a1, zero, 1
sw a0, 552(gp)
sw a1, 552(a2)

addi a0, zero, 72
addi a1, zero, 1
sw a0, 560(gp)
sw a1, 560(a2)

addi a0, zero, 48
addi a1, zero, 1
sw a0, 568(gp)
sw a1, 568(a2)

addi a0, zero, 116
addi a1, zero, 1
sw a0, 576(gp)
sw a1, 576(a2)

addi a0, zero, 116
addi a1, zero, 1
sw a0, 584(gp)
sw a1, 584(a2)

addi a0, zero, 64
addi a1, zero, 1
sw a0, 592(gp)
sw a1, 592(a2)

addi a0, zero, 108
addi a1, zero, 1
sw a0, 600(gp)
sw a1, 600(a2)

addi a0, zero, 108
addi a1, zero, 1
sw a0, 608(gp)
sw a1, 608(a2)

addi a0, zero, 72
addi a1, zero, 1
sw a0, 632(gp)
sw a1, 632(a2)

addi a0, zero, 68
addi a1, zero, 1
sw a0, 664(gp)
sw a1, 664(a2)

addi a0, zero, 116
addi a1, zero, 1
sw a0, 680(gp)
sw a1, 680(a2)

addi a0, zero, 36
addi a1, zero, 1
sw a0, 688(gp)
sw a1, 688(a2)

addi a0, zero, 96
addi a1, zero, 1
sw a0, 712(gp)
sw a1, 712(a2)

addi a0, zero, 36
addi a1, zero, 1
sw a0, 720(gp)
sw a1, 720(a2)

addi a0, zero, 92
addi a1, zero, 1
sw a0, 728(gp)
sw a1, 728(a2)

addi a0, zero, 68
addi a1, zero, 1
sw a0, 744(gp)
sw a1, 744(a2)

addi a0, zero, 24
addi a1, zero, 1
sw a0, 752(gp)
sw a1, 752(a2)

addi a0, zero, 96
addi a1, zero, 1
sw a0, 760(gp)
sw a1, 760(a2)

addi a0, zero, 80
addi a1, zero, 1
sw a0, 784(gp)
sw a1, 784(a2)

addi a0, zero, 52
addi a1, zero, 1
sw a0, 792(gp)
sw a1, 792(a2)

addi a0, zero, 100
addi a1, zero, 1
sw a0, 800(gp)
sw a1, 800(a2)

addi a0, zero, 48
addi a1, zero, 1
sw a0, 824(gp)
sw a1, 824(a2)

addi a0, zero, 92
addi a1, zero, 1
sw a0, 832(gp)
sw a1, 832(a2)

addi a0, zero, 40
addi a1, zero, 1
sw a0, 840(gp)
sw a1, 840(a2)

addi a0, zero, 116
addi a1, zero, 1
sw a0, 848(gp)
sw a1, 848(a2)

addi a0, zero, 84
addi a1, zero, 1
sw a0, 880(gp)
sw a1, 880(a2)

addi a0, zero, 60
addi a1, zero, 1
sw a0, 888(gp)
sw a1, 888(a2)

addi a0, zero, 72
addi a1, zero, 1
sw a0, 896(gp)
sw a1, 896(a2)

addi a0, zero, 12
addi a1, zero, 1
sw a0, 904(gp)
sw a1, 904(a2)

addi a0, zero, 108
addi a1, zero, 1
sw a0, 928(gp)
sw a1, 928(a2)

addi a0, zero, 28
addi a1, zero, 1
sw a0, 936(gp)
sw a1, 936(a2)

addi a0, zero, 80
addi a1, zero, 1
sw a0, 984(gp)
sw a1, 984(a2)

    # 显示飞机

    sw s0, -8(s5)
    sw s1, -4(s5)
    sw s2,  0(s5)
    sw s3,  4(s5)
    sw s4,  8(s5)


    # 进入循环
nop_cycle:
    addi zero, zero,0
    addi zero, zero,0
    addi zero, zero,0
    addi zero, zero,0
    addi zero, zero,0
    beq ra, zero, nop_cycle
    # 显示飞机
    addi   a7, zero, 35
    ecall
    # 游戏开始
    addi gp, gp, -1024
    addi a5, gp, 0           # 计数器
    addi a6, a5, 1024        # 计数器上限
    addi a3, zero, 0         # 难度
    addi a4, zero, 1         # 难度上限
game_next_pic:        
                             # 生成新的金币
    lw a0, 0(a5)             # a0是行数*4
    lw a1, 4(a5)             # a1是金币
    lw a2, 128(a0)           # a2是中间变量
    add a2, a2, a1  
    sw a2, 128(a0)

    addi a7, zero, 90        # 全体左移
    ecall

    addi a7, zero, 34        # 显示屏幕
    ecall

    addi tp, zero, 0         # 调用检查中断
    addi a7, zero, 37        # 这里用了系统调用,系统调用会触发一个外部中断,相当于实现了软中断
    ecall     

    wait_for_check:
    addi zero, zero, 0
    beq tp, zero, wait_for_check
    addi tp, zero, 0

    # 检差是否碰撞,并消除

    addi a5, a5, 8
    bne a5, a6, game_next_pic
    addi a5, gp, 0      # 512是初始地址
    addi a3, a3, 1    # 难度加1
    bne a3, a4, game_next_pic
    addi gp, gp, 1024
    addi a5, gp, 0
    addi a6, gp, 1024
    beq zero, zero, game_next_pic