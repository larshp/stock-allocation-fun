CLASS zcl_alloc_cost_split DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_weight,
             name   TYPE string,
             weight TYPE i,
           END OF ty_weight.
    TYPES ty_weight_tt TYPE STANDARD TABLE OF ty_weight WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_component,
             name   TYPE string,
             amount TYPE i,
           END OF ty_component.
    TYPES ty_component_tt TYPE STANDARD TABLE OF ty_component WITH DEFAULT KEY.

    METHODS split
      IMPORTING
        iv_total             TYPE i
        it_weights           TYPE ty_weight_tt
      RETURNING
        VALUE(rt_components) TYPE ty_component_tt.

    METHODS share_of
      IMPORTING
        it_components    TYPE ty_component_tt
        iv_name          TYPE string
      RETURNING
        VALUE(rv_amount) TYPE i.

    METHODS component_count
      IMPORTING
        it_components   TYPE ty_component_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_cost_split IMPLEMENTATION.

  METHOD split.
    DATA lv_weight_sum TYPE i.
    DATA ls_component TYPE ty_component.

    " The total is spread over the components by their weight.
    LOOP AT it_weights INTO DATA(ls_weight).
      lv_weight_sum = lv_weight_sum + ls_weight-weight.
    ENDLOOP.

    IF lv_weight_sum <= 0.
      RETURN.
    ENDIF.

    LOOP AT it_weights INTO ls_weight.
      ls_component-name = ls_weight-name.
      ls_component-amount = iv_total * ls_weight-weight DIV lv_weight_sum.
      APPEND ls_component TO rt_components.
    ENDLOOP.
  ENDMETHOD.

  METHOD share_of.
    " The share of a component is looked up by its name.
    LOOP AT it_components INTO DATA(ls_component).
      IF ls_component-name = iv_name.
        rv_amount = ls_component-amount.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD component_count.
    rv_count = lines( it_components ).
  ENDMETHOD.

ENDCLASS.
