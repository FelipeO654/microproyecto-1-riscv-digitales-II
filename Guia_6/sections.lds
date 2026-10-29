ENTRY(_start)
MEMORY {
    FLASH (rx) : ORIGIN = 0x00000000, LENGTH = 16K
    SRAM  (rw) : ORIGIN = 0x00001000, LENGTH = 12K
}
SECTIONS {
    .flash : {
        *(.text) *(.text.*)
        *(.rodata) *(.rodata.*)
        *(.srodata) *(.srodata.*)
        *(.eh_frame) *(.eh_frame.*)
        . = ALIGN(4);
    } > FLASH
    .sram : {
        *(.data) *(.data.*)
        *(.sdata) *(.sdata.*)
        *(.bss) *(.bss.*)
        *(COMMON)
        . = ALIGN(4);
    } > SRAM
}
