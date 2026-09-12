CLASS zcl_alloc_maxmin DEFINITION
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

    METHODS allocate
      IMPORTING
        it_demands       TYPE ty_qty_tt
        iv_available     TYPE menge_d
      RETURNING
        VALUE(rt_grants) TYPE ty_grant_tt.

  PRIVATE SECTION.
    METHODS to_grants
      IMPORTING
        it_granted       TYPE ty_qty_tt
      RETURNING
        VALUE(rt_grants) TYPE ty_grant_tt.

ENDCLASS.


CLASS zcl_alloc_maxmin IMPLEMENTATION.

  METHOD to_grants.
    DATA ls_grant TYPE ty_grant.

    LOOP AT it_granted INTO DATA(lv_value).
      CLEAR ls_grant.
      ls_grant-index = sy-tabix.
      ls_grant-granted = lv_value.
      APPEND ls_grant TO rt_grants.
    ENDLOOP.
  ENDMETHOD.

  METHOD allocate.
    DATA lt_granted  TYPE ty_qty_tt.
    DATA lv_remaining TYPE menge_d.
    DATA lv_active    TYPE i.
    DATA lv_share     TYPE menge_d.
    DATA lv_index     TYPE i.
    DATA lv_give      TYPE menge_d.
    DATA lv_demand    TYPE menge_d.
    DATA lv_more      TYPE abap_bool.

    lv_remaining = iv_available.

    LOOP AT it_demands INTO lv_demand.
      APPEND 0 TO lt_granted.
    ENDLOOP.

    lv_more = abap_true.

    WHILE lv_more = abap_true.
      lv_active = 0.
      LOOP AT lt_granted INTO DATA(lv_granted).
        READ TABLE it_demands INTO lv_demand INDEX sy-tabix.
        IF lv_demand > lv_granted.
          lv_active = lv_active + 1.
        ENDIF.
      ENDLOOP.

      IF lv_remaining <= 0 OR lv_active = 0.
        lv_more = abap_false.
      ELSE.
        lv_share = lv_remaining DIV lv_active.

        IF lv_share <= 0.
          lv_index = 1.
          LOOP AT lt_granted ASSIGNING FIELD-SYMBOL(<lv_granted>).
            IF lv_remaining > 0.
              READ TABLE it_demands INTO lv_demand INDEX lv_index.
              IF lv_demand > <lv_granted>.
                <lv_granted> = <lv_granted> + 1.
                lv_remaining = lv_remaining - 1.
              ENDIF.
            ENDIF.
            lv_index = lv_index + 1.
          ENDLOOP.
          lv_more = abap_false.
        ELSE.
          lv_index = 1.
          LOOP AT lt_granted ASSIGNING <lv_granted>.
            READ TABLE it_demands INTO lv_demand INDEX lv_index.
            IF lv_demand > <lv_granted>.
              lv_give = lv_demand - <lv_granted>.
              IF lv_give > lv_share.
                lv_give = lv_share.
              ENDIF.
              <lv_granted> = <lv_granted> + lv_give.
              lv_remaining = lv_remaining - lv_give.
            ENDIF.
            lv_index = lv_index + 1.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDWHILE.

    rt_grants = to_grants( lt_granted ).
  ENDMETHOD.

ENDCLASS.
