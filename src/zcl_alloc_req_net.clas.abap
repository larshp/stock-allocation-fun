CLASS zcl_alloc_req_net DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_result,
             requirements    TYPE zif_requirement_reader=>ty_requirement_tt,
             covered_qty     TYPE menge_d,
             remaining_stock TYPE menge_d,
           END OF ty_result.

    METHODS net
      IMPORTING
        it_requirements  TYPE zif_requirement_reader=>ty_requirement_tt
        iv_stock         TYPE menge_d
      RETURNING
        VALUE(rs_result) TYPE ty_result.

ENDCLASS.


CLASS zcl_alloc_req_net IMPLEMENTATION.

  METHOD net.
    DATA lt_sorted TYPE zif_requirement_reader=>ty_requirement_tt.
    DATA ls_net    TYPE zif_requirement_reader=>ty_requirement.
    DATA lv_left   TYPE menge_d.
    DATA lv_take   TYPE menge_d.

    lt_sorted = it_requirements.
    SORT lt_sorted BY requested_date ASCENDING
                      id ASCENDING.

    lv_left = iv_stock.

    LOOP AT lt_sorted INTO DATA(ls_requirement).
      CLEAR ls_net.
      ls_net = ls_requirement.

      lv_take = ls_requirement-requested_qty.
      IF lv_take > lv_left.
        lv_take = lv_left.
      ENDIF.
      IF lv_take < 0.
        lv_take = 0.
      ENDIF.

      ls_net-requested_qty = ls_requirement-requested_qty - lv_take.
      rs_result-covered_qty = rs_result-covered_qty + lv_take.
      lv_left = lv_left - lv_take.

      IF ls_net-requested_qty > 0.
        APPEND ls_net TO rs_result-requirements.
      ENDIF.
    ENDLOOP.

    rs_result-remaining_stock = lv_left.
  ENDMETHOD.

ENDCLASS.
