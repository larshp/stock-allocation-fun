CLASS ltcl_reader DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS scoped_stock FOR TESTING.
    METHODS unknown_material FOR TESTING.
    METHODS missing_plant FOR TESTING.
    METHODS foreign_client_only FOR TESTING.
ENDCLASS.

CLASS ltcl_reader IMPLEMENTATION.
  METHOD scoped_stock.
    DATA reader TYPE REF TO zif_stock_reader.
    reader = NEW zcl_stock_reader_mard( ).
    DATA(stock) = reader->read_stock( iv_material = 'MAT1' iv_plant = '1000' ).
    cl_abap_unit_assert=>assert_equals( act = lines( stock ) exp = 2 ).
    LOOP AT stock INTO DATA(row).
      cl_abap_unit_assert=>assert_equals( act = row-mandt exp = sy-mandt ).
    ENDLOOP.
    READ TABLE stock INDEX 1 INTO DATA(first).
    cl_abap_unit_assert=>assert_equals( act = first-lgort exp = '0001' ).
    cl_abap_unit_assert=>assert_equals( act = first-labst exp = '4.500' ).
  ENDMETHOD.

  METHOD unknown_material.
    DATA reader TYPE REF TO zif_stock_reader.
    reader = NEW zcl_stock_reader_mard( ).
    DATA(stock) = reader->read_stock( iv_material = 'UNKNOWN' iv_plant = '1000' ).
    cl_abap_unit_assert=>assert_initial( stock ).
  ENDMETHOD.

  METHOD missing_plant.
    DATA reader TYPE REF TO zif_stock_reader.
    reader = NEW zcl_stock_reader_mard( ).
    DATA(stock) = reader->read_stock( iv_material = 'MAT1' iv_plant = '' ).
    cl_abap_unit_assert=>assert_initial( stock ).
  ENDMETHOD.

  METHOD foreign_client_only.
    DATA reader TYPE REF TO zif_stock_reader.
    reader = NEW zcl_stock_reader_mard( ).
    DATA(stock) = reader->read_stock( iv_material = 'FOREIGN' iv_plant = '1000' ).
    cl_abap_unit_assert=>assert_initial( stock ).
  ENDMETHOD.
ENDCLASS.
