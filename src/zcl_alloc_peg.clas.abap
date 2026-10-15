CLASS zcl_alloc_peg DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_req,
             material    TYPE matnr,
             requirement TYPE i,
             supply      TYPE i,
           END OF ty_req.
    TYPES ty_req_tt TYPE STANDARD TABLE OF ty_req WITH DEFAULT KEY.

    METHODS peg
      IMPORTING
        is_req        TYPE ty_req
      RETURNING
        VALUE(rv_peg) TYPE i.

    METHODS is_pegged
      IMPORTING
        is_req       TYPE ty_req
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS peg_count
      IMPORTING
        it_reqs         TYPE ty_req_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_peg IMPLEMENTATION.

  METHOD peg.
    DATA lv_requirement TYPE i.
    DATA lv_supply      TYPE i.

    " The pegged quantity is the smaller of the requirement and the supply.
    lv_requirement = is_req-requirement.
    lv_supply = is_req-supply.
    IF lv_requirement < 0.
      lv_requirement = 0.
    ENDIF.
    IF lv_supply < 0.
      lv_supply = 0.
    ENDIF.

    IF lv_requirement < lv_supply.
      rv_peg = lv_requirement.
    ELSE.
      rv_peg = lv_supply.
    ENDIF.
  ENDMETHOD.

  METHOD is_pegged.
    " A requirement is fully pegged while the supply reaches it.
    rv_ok = xsdbool( is_req-supply >= is_req-requirement ).
  ENDMETHOD.

  METHOD peg_count.
    LOOP AT it_reqs INTO DATA(ls_req).
      IF is_pegged( ls_req ) = abap_true.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
