################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../drivers/mss_uart/mss_uart.c 

OBJS += \
./drivers/mss_uart/mss_uart.o 

C_DEPS += \
./drivers/mss_uart/mss_uart.d 


# Each subdirectory must supply rules for building sources it contributes
drivers/mss_uart/%.o: ../drivers/mss_uart/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: GNU ARM Cross C Compiler'
	arm-none-eabi-gcc -mcpu=cortex-m3 -mthumb -O0 -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections  -g3 -I"C:\Microchip\SoftConsole-v2021.1\extras\workspace.examples\IAP_M2S005\drivers" -I"C:\Microchip\SoftConsole-v2021.1\extras\workspace.examples\IAP_M2S005\drivers\mss_gpio" -I"C:\Microchip\SoftConsole-v2021.1\extras\workspace.examples\IAP_M2S005\windbondflash" -I"C:\Microchip\SoftConsole-v2021.1\extras\workspace.examples\IAP_M2S005\drivers\mss_sys_services" -I"C:\Microchip\SoftConsole-v2021.1\extras\workspace.examples\IAP_M2S005\drivers\mss_spi" -I"C:\Microchip\SoftConsole-v2021.1\extras\workspace.examples\IAP_M2S005\drivers\mss_uart" -std=gnu11 --specs=cmsis.specs -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


