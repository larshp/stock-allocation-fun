CLASS zcl_alloc_flags DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_flag TYPE c LENGTH 20.

    TYPES: BEGIN OF ty_flag_entry,
             name    TYPE ty_flag,
             enabled TYPE abap_bool,
           END OF ty_flag_entry.
    TYPES ty_flag_tt TYPE STANDARD TABLE OF ty_flag_entry WITH DEFAULT KEY.

    METHODS set
      IMPORTING
        iv_name    TYPE ty_flag
        iv_enabled TYPE abap_bool.

    METHODS is_enabled
      IMPORTING
        iv_name           TYPE ty_flag
      RETURNING
        VALUE(rv_enabled) TYPE abap_bool.

    METHODS count
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS enabled_flags
      RETURNING
        VALUE(rt_flags) TYPE ty_flag_tt.

  PRIVATE SECTION.
    DATA mt_flags TYPE ty_flag_tt.

ENDCLASS.


CLASS zcl_alloc_flags IMPLEMENTATION.

  METHOD set.
    READ TABLE mt_flags ASSIGNING FIELD-SYMBOL(<ls_flag>) WITH KEY name = iv_name.

    IF sy-subrc = 0.
      <ls_flag>-enabled = iv_enabled.
    ELSE.
      APPEND VALUE #( name = iv_name enabled = iv_enabled ) TO mt_flags.
    ENDIF.
  ENDMETHOD.

  METHOD is_enabled.
    DATA ls_flag TYPE ty_flag_entry.

    READ TABLE mt_flags INTO ls_flag WITH KEY name = iv_name.

    IF sy-subrc = 0.
      rv_enabled = ls_flag-enabled.
    ELSE.
      rv_enabled = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD count.
    rv_count = lines( mt_flags ).
  ENDMETHOD.

  METHOD enabled_flags.
    DATA ls_flag TYPE ty_flag_entry.

    LOOP AT mt_flags INTO ls_flag.
      IF ls_flag-enabled = abap_true.
        APPEND ls_flag TO rt_flags.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
