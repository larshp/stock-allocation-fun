CLASS zcl_alloc_capacity DEFINITION
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
        iv_capacity      TYPE menge_d
      RETURNING
        VALUE(rt_grants) TYPE ty_grant_tt.

ENDCLASS.


CLASS zcl_alloc_capacity IMPLEMENTATION.

  METHOD allocate.
    DATA ls_grant TYPE ty_grant.
    DATA lv_left  TYPE menge_d.
    DATA lv_give  TYPE menge_d.

    lv_left = iv_capacity.

    LOOP AT it_demands INTO DATA(lv_demand).
      lv_give = lv_demand.
      IF lv_give < 0.
        lv_give = 0.
      ENDIF.
      IF lv_give > lv_left.
        lv_give = lv_left.
      ENDIF.

      CLEAR ls_grant.
      ls_grant-index = sy-tabix.
      ls_grant-granted = lv_give.
      APPEND ls_grant TO rt_grants.

      lv_left = lv_left - lv_give.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
