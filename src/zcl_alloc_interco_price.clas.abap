CLASS zcl_alloc_interco_price DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_component,
             name   TYPE string,
             amount TYPE i,
           END OF ty_component.
    TYPES ty_component_tt TYPE STANDARD TABLE OF ty_component WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_price,
             component_count TYPE i,
             total           TYPE i,
           END OF ty_price.

    METHODS build
      IMPORTING
        it_components   TYPE ty_component_tt
      RETURNING
        VALUE(rs_price) TYPE ty_price.

    METHODS total
      IMPORTING
        it_components   TYPE ty_component_tt
      RETURNING
        VALUE(rv_total) TYPE i.

    METHODS is_positive
      IMPORTING
        it_components TYPE ty_component_tt
      RETURNING
        VALUE(rv_ok)  TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_interco_price IMPLEMENTATION.

  METHOD total.
    " The transfer price is the sum of its components.
    LOOP AT it_components INTO DATA(ls_component).
      rv_total = rv_total + ls_component-amount.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_positive.
    DATA lv_total TYPE i.

    " A transfer price that adds up to something is positive.
    lv_total = total( it_components ).
    rv_ok = xsdbool( lv_total > 0 ).
  ENDMETHOD.

  METHOD build.
    " The result counts the components and totals the price.
    rs_price-component_count = lines( it_components ).
    rs_price-total = total( it_components ).
  ENDMETHOD.

ENDCLASS.
