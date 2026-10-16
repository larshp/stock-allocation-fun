CLASS zcl_alloc_proportional DEFINITION
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

  PRIVATE SECTION.
    METHODS to_grants
      IMPORTING
        it_granted       TYPE ty_qty_tt
      RETURNING
        VALUE(rt_grants) TYPE ty_grant_tt.

ENDCLASS.


CLASS zcl_alloc_proportional IMPLEMENTATION.

  METHOD to_grants.
    DATA ls_grant TYPE ty_grant.

    LOOP AT it_granted INTO DATA(lv_value).
      CLEAR ls_grant.
      ls_grant-index = sy-tabix.
      ls_grant-granted = lv_value.
      APPEND ls_grant TO rt_grants.
    ENDLOOP.
  ENDMETHOD.

  METHOD distribute.
    DATA lt_granted TYPE ty_qty_tt.
    DATA lv_total   TYPE menge_d.
    DATA lv_assigned TYPE menge_d.
    DATA lv_left    TYPE menge_d.
    DATA lv_index   TYPE i.
    DATA lv_give    TYPE menge_d.
    DATA lv_demand  TYPE menge_d.

    LOOP AT it_demands INTO lv_demand.
      APPEND 0 TO lt_granted.
      IF lv_demand > 0.
        lv_total = lv_total + lv_demand.
      ENDIF.
    ENDLOOP.

    IF lv_total > 0 AND iv_available > 0.
      lv_index = 1.
      LOOP AT lt_granted ASSIGNING FIELD-SYMBOL(<lv_granted>).
        READ TABLE it_demands INTO lv_demand INDEX lv_index.
        lv_give = iv_available * lv_demand DIV lv_total.
        IF lv_give > lv_demand.
          lv_give = lv_demand.
        ENDIF.
        <lv_granted> = lv_give.
        lv_assigned = lv_assigned + lv_give.
        lv_index = lv_index + 1.
      ENDLOOP.

      lv_left = iv_available - lv_assigned.
      lv_index = 1.
      LOOP AT lt_granted ASSIGNING <lv_granted>.
        IF lv_left <= 0.
          EXIT.
        ENDIF.
        READ TABLE it_demands INTO lv_demand INDEX lv_index.
        IF <lv_granted> < lv_demand.
          <lv_granted> = <lv_granted> + 1.
          lv_left = lv_left - 1.
        ENDIF.
        lv_index = lv_index + 1.
      ENDLOOP.
    ENDIF.

    rt_grants = to_grants( lt_granted ).
  ENDMETHOD.

ENDCLASS.
