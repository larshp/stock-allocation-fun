CLASS zcl_alloc_landed_build DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_component,
             name   TYPE string,
             amount TYPE i,
           END OF ty_component.
    TYPES ty_component_tt TYPE STANDARD TABLE OF ty_component WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_landed,
             component_count TYPE i,
             total           TYPE i,
           END OF ty_landed.

    METHODS build
      IMPORTING
        it_components    TYPE ty_component_tt
      RETURNING
        VALUE(rs_landed) TYPE ty_landed.

    METHODS component_count
      IMPORTING
        it_components   TYPE ty_component_tt
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS total
      IMPORTING
        it_components   TYPE ty_component_tt
      RETURNING
        VALUE(rv_total) TYPE i.

ENDCLASS.


CLASS zcl_alloc_landed_build IMPLEMENTATION.

  METHOD component_count.
    rv_count = lines( it_components ).
  ENDMETHOD.

  METHOD total.
    " The landed cost is the sum of every component on top of the base.
    LOOP AT it_components INTO DATA(ls_component).
      rv_total = rv_total + ls_component-amount.
    ENDLOOP.
  ENDMETHOD.

  METHOD build.
    " The result counts the components and totals the landed cost.
    rs_landed-component_count = component_count( it_components ).
    rs_landed-total = total( it_components ).
  ENDMETHOD.

ENDCLASS.
