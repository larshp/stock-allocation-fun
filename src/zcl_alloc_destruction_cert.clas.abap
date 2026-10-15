CLASS zcl_alloc_destruction_cert DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             material TYPE matnr,
             quantity TYPE i,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_cert,
             cert_no        TYPE string,
             quantity_total TYPE i,
             line_count     TYPE i,
           END OF ty_cert.

    METHODS build
      IMPORTING
        it_items       TYPE ty_item_tt
        iv_cert_no     TYPE string
      RETURNING
        VALUE(rs_cert) TYPE ty_cert.

    METHODS is_complete
      IMPORTING
        is_cert      TYPE ty_cert
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS quantity_total
      IMPORTING
        it_items      TYPE ty_item_tt
      RETURNING
        VALUE(rv_qty) TYPE i.

ENDCLASS.


CLASS zcl_alloc_destruction_cert IMPLEMENTATION.

  METHOD quantity_total.
    LOOP AT it_items INTO DATA(ls_item).
      IF ls_item-quantity > 0.
        rv_qty = rv_qty + ls_item-quantity.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD build.
    DATA lv_count TYPE i.

    " The certificate carries the reference number, the destroyed quantity and the
    " number of material lines that went into it.
    rs_cert-cert_no = iv_cert_no.
    rs_cert-quantity_total = quantity_total( it_items ).

    LOOP AT it_items INTO DATA(ls_item).
      IF ls_item-quantity > 0.
        lv_count = lv_count + 1.
      ENDIF.
    ENDLOOP.

    rs_cert-line_count = lv_count.
  ENDMETHOD.

  METHOD is_complete.
    rv_ok = xsdbool( is_cert-cert_no IS NOT INITIAL
                     AND is_cert-quantity_total > 0 ).
  ENDMETHOD.

ENDCLASS.
