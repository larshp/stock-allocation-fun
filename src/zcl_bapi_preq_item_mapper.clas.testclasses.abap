CLASS ltcl_bapi_preq_item_mapper DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS maps_selected_vendor FOR TESTING.
    METHODS maps_item_deletion FOR TESTING.
    METHODS maps_item_updates FOR TESTING.
ENDCLASS.

CLASS ltcl_bapi_preq_item_mapper IMPLEMENTATION.
  METHOD maps_selected_vendor.
    zcl_bapi_preq_item_mapper=>map_items(
      EXPORTING
        it_items      = VALUE #(
          ( item_number        = '00010'
            source_vendor      = '0000100001'
            source_info_record = '0000001234'
            purchasing_org     = '2000'
            material           = 'MAT-SOURCE'
            plant              = '1000'
            quantity           = '2.000'
            unit               = 'EA'
            delivery_date      = '20261115' )
          ( item_number   = '00020'
            material      = 'MAT-AUTO'
            plant         = '1000'
            quantity      = '1.000'
            unit          = 'EA'
            delivery_date = '20261116' ) )
      IMPORTING
        et_items      = DATA(lt_bapi_items)
        et_item_flags = DATA(lt_item_flags) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_bapi_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lt_bapi_items[ 1 ]-fixed_vend ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000001234'
      act = lt_bapi_items[ 1 ]-info_rec ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = lt_bapi_items[ 1 ]-purch_org ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_item_flags[ 1 ]-fixed_vend ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_item_flags[ 1 ]-info_rec ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_item_flags[ 1 ]-purch_org ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_bapi_items[ 2 ]-fixed_vend ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_bapi_items[ 2 ]-info_rec ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_item_flags[ 2 ]-fixed_vend ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_item_flags[ 2 ]-info_rec ).
    zcl_bapi_preq_item_mapper=>map_items(
      EXPORTING
        it_items      = VALUE #(
          ( item_number           = '00030'
            source_vendor         = '0000100003'
            purchasing_org        = '3000'
            source_agreement      = '4500000001'
            source_agreement_item = '00010'
            material              = 'MAT-CONTRACT'
            plant                 = '1000'
            quantity              = '3.000'
            unit                  = 'EA'
            delivery_date         = '20261117' ) )
      IMPORTING
        et_items      = DATA(lt_agreement_items)
        et_item_flags = DATA(lt_agreement_flags) ).

    cl_abap_unit_assert=>assert_equals(
      exp = '4500000001'
      act = lt_agreement_items[ 1 ]-agreement ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00010'
      act = lt_agreement_items[ 1 ]-agmt_item ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_agreement_flags[ 1 ]-agreement ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_agreement_flags[ 1 ]-agmt_item ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_agreement_flags[ 1 ]-info_rec ).
  ENDMETHOD.

  METHOD maps_item_deletion.
    zcl_bapi_preq_item_mapper=>map_deleted_items(
      EXPORTING
        it_item_numbers = VALUE #(
          ( '00010' )
          ( '00030' ) )
      IMPORTING
        et_items        = DATA(lt_items)
        et_item_flags   = DATA(lt_item_flags) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00010'
      act = lt_items[ 1 ]-preq_item ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_items[ 1 ]-delete_ind ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00030'
      act = lt_item_flags[ 2 ]-preq_item ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_item_flags[ 2 ]-preq_itemx ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_item_flags[ 2 ]-delete_ind ).
  ENDMETHOD.

  METHOD maps_item_updates.
    zcl_bapi_preq_item_mapper=>map_item_updates(
      EXPORTING
        it_item_updates = VALUE #(
          ( item_number     = '00010'
            change_quantity = abap_true
            quantity        = '7.000' )
          ( item_number          = '00020'
            change_delivery_date = abap_true
            delivery_date        = '20261201' )
          ( item_number                  = '00030'
            change_purchasing_group      = abap_true
            purchasing_group             = '007'
            change_purchasing_org        = abap_true
            purchasing_org               = '2000'
            change_source_vendor         = abap_true
            source_vendor                = '0000100001'
            change_source_info_record    = abap_true
            source_info_record           = '0000001234'
            change_source_agreement      = abap_true
            source_agreement             = '4500000001'
            change_source_agreement_item = abap_true
            source_agreement_item        = '00010' )
          ( item_number          = '00040'
            change_source_vendor = abap_true ) )
      IMPORTING
        et_items        = DATA(lt_items)
        et_item_flags   = DATA(lt_item_flags) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( lt_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00010'
      act = lt_items[ 1 ]-preq_item ).
    cl_abap_unit_assert=>assert_equals(
      exp = '7.000'
      act = lt_items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_item_flags[ 1 ]-preq_itemx ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_item_flags[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_item_flags[ 1 ]-deliv_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00020'
      act = lt_items[ 2 ]-preq_item ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261201'
      act = lt_items[ 2 ]-deliv_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_item_flags[ 2 ]-deliv_date ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_item_flags[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '007'
      act = lt_items[ 3 ]-pur_group ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = lt_items[ 3 ]-purch_org ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lt_items[ 3 ]-fixed_vend ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000001234'
      act = lt_items[ 3 ]-info_rec ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000001'
      act = lt_items[ 3 ]-agreement ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00010'
      act = lt_items[ 3 ]-agmt_item ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_item_flags[ 3 ]-pur_group ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_item_flags[ 3 ]-purch_org ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_item_flags[ 3 ]-fixed_vend ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_item_flags[ 3 ]-info_rec ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_item_flags[ 3 ]-agreement ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_item_flags[ 3 ]-agmt_item ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_items[ 4 ]-fixed_vend ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_item_flags[ 4 ]-fixed_vend ).
  ENDMETHOD.
ENDCLASS.
