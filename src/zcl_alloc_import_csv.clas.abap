CLASS zcl_alloc_import_csv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_fields_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS parse_line
      IMPORTING
        iv_line          TYPE string
      RETURNING
        VALUE(rt_fields) TYPE ty_fields_tt.

    METHODS count_of
      IMPORTING
        iv_line         TYPE string
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_import_csv IMPLEMENTATION.

  METHOD parse_line.
    DATA lv_len       TYPE i.
    DATA lv_pos       TYPE i.
    DATA lv_char      TYPE string.
    DATA lv_next      TYPE string.
    DATA lv_in_quotes TYPE abap_bool.
    DATA lv_current   TYPE string.

    lv_len = strlen( iv_line ).

    WHILE lv_pos < lv_len.
      lv_char = substring( val = iv_line off = lv_pos len = 1 ).
      lv_pos = lv_pos + 1.

      IF lv_char = '"'.
        IF lv_in_quotes = abap_true.
          IF lv_pos < lv_len.
            lv_next = substring( val = iv_line off = lv_pos len = 1 ).
          ELSE.
            lv_next = ''.
          ENDIF.

          IF lv_next = '"'.
            lv_current = lv_current && '"'.
            lv_pos = lv_pos + 1.
          ELSE.
            lv_in_quotes = abap_false.
          ENDIF.
        ELSE.
          lv_in_quotes = abap_true.
        ENDIF.
      ELSEIF lv_char = ';' AND lv_in_quotes = abap_false.
        APPEND lv_current TO rt_fields.
        lv_current = ''.
      ELSE.
        lv_current = lv_current && lv_char.
      ENDIF.
    ENDWHILE.

    APPEND lv_current TO rt_fields.
  ENDMETHOD.

  METHOD count_of.
    DATA lt_fields TYPE ty_fields_tt.

    lt_fields = parse_line( iv_line ).

    rv_count = lines( lt_fields ).
  ENDMETHOD.

ENDCLASS.
