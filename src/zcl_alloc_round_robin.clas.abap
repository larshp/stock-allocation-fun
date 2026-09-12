CLASS zcl_alloc_round_robin DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_qty_tt TYPE STANDARD TABLE OF menge_d WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_grant,
             index   TYPE i,
             granted TYPE menge_d,
           END OF ty_grant.
    TYPES ty_grant_tt TYPE STANDARD TABLE OF ty_grant WITH DEFAULT KEY.

    METHODS distribute
      IMPORTING
        it_demands       TYPE ty_qty_tt
        iv_available     TYPE menge_d
      RETURNING
        VALUE(rt_grants) TYPE ty_grant_tt.

ENDCLASS.


CLASS zcl_alloc_round_robin IMPLEMENTATION.

  METHOD distribute.
    DATA lt_granted  TYPE STANDARD TABLE OF menge_d WITH DEFAULT KEY.
    DATA ls_grant    TYPE ty_grant.
    DATA lv_remaining TYPE menge_d.
    DATA lv_progress  TYPE abap_bool.
    DATA lv_index     TYPE i.
    DATA lv_demand    TYPE menge_d.

    lv_remaining = iv_available.

    LOOP AT it_demands INTO DATA(lv_qty).
      APPEND 0 TO lt_granted.
      IF lv_qty < 0.
        CONTINUE.
      ENDIF.
    ENDLOOP.

    lv_progress = abap_true.

    WHILE lv_remaining > 0 AND lv_progress = abap_true.
      lv_progress = abap_false.
      lv_index = 1.

      LOOP AT lt_granted ASSIGNING FIELD-SYMBOL(<lv_granted>).
        IF lv_remaining <= 0.
          EXIT.
        ENDIF.

        READ TABLE it_demands INTO lv_demand INDEX lv_index.
        IF sy-subrc = 0 AND lv_demand > <lv_granted>.
          <lv_granted> = <lv_granted> + 1.
          lv_remaining = lv_remaining - 1.
          lv_progress = abap_true.
        ENDIF.

        lv_index = lv_index + 1.
      ENDLOOP.
    ENDWHILE.

    lv_index = 1.
    LOOP AT lt_granted INTO DATA(lv_value).
      CLEAR ls_grant.
      ls_grant-index = lv_index.
      ls_grant-granted = lv_value.
      APPEND ls_grant TO rt_grants.
      lv_index = lv_index + 1.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
