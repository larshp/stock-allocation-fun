CLASS ltcl_alloc_sto_create DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_sto_create.
    DATA mt_line TYPE zcl_alloc_sto_create=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material   TYPE matnr
        iv_from_plant TYPE string
        iv_to_plant   TYPE string
        iv_quantity   TYPE i.

    METHODS builds_order    FOR TESTING.
    METHODS cross_plant_rule FOR TESTING.
    METHODS sums_quantity   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_sto_create IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_sto_create( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_sto_create=>ty_line.

    ls_line-material = iv_material.
    ls_line-from_plant = iv_from_plant.
    ls_line-to_plant = iv_to_plant.
    ls_line-quantity = iv_quantity.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD builds_order.
    DATA ls_sto TYPE zcl_alloc_sto_create=>ty_sto.

    add( iv_material = 'M1' iv_from_plant = 'P1' iv_to_plant = 'P2'
         iv_quantity = 10 ).
    add( iv_material = 'M2' iv_from_plant = 'P1' iv_to_plant = 'P1'
         iv_quantity = 5 ).

    ls_sto = mo_cut->build( mt_line ).

    cl_abap_unit_assert=>assert_equals( act = ls_sto-line_count exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_sto-total_quantity exp = 15 ).
  ENDMETHOD.

  METHOD cross_plant_rule.
    add( iv_material = 'M1' iv_from_plant = 'P1' iv_to_plant = 'P2'
         iv_quantity = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_cross_plant( mt_line ) exp = abap_true ).
  ENDMETHOD.

  METHOD sums_quantity.
    add( iv_material = 'M1' iv_from_plant = 'P1' iv_to_plant = 'P2'
         iv_quantity = 10 ).
    add( iv_material = 'M2' iv_from_plant = 'P1' iv_to_plant = 'P1'
         iv_quantity = 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_quantity( mt_line ) exp = 15 ).
  ENDMETHOD.

ENDCLASS.
