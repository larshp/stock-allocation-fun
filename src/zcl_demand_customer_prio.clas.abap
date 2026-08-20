CLASS zcl_demand_customer_prio DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_demand_reader.

    "! <p class="shorttext synchronized">Serve certain customers before the rest</p>
    "!
    "! Delivery priority is a property of the order, set when it was typed in.
    "! Which customers a business would rather disappoint last is not: it is a
    "! standing decision, it changes without the orders changing, and nobody is
    "! going to maintain it on every order line. `ZSTOCK_ALLOC_PRI` says it
    "! once per customer, and this puts it on the demand.
    "!
    "! @parameter io_demand | <p class="shorttext synchronized">Reader of the demand as the documents have it</p>
    METHODS constructor
      IMPORTING
        io_demand TYPE REF TO zif_demand_reader.

  PRIVATE SECTION.

    "! One customer that is served before or after the rest. Declared
    "! explicitly rather than inferred with INTO TABLE @DATA(), see
    "! ANOMALIES.md.
    TYPES:
      BEGIN OF ty_rank,
        werks    TYPE zstock_alloc_pri-werks,
        kunnr    TYPE zstock_alloc_pri-kunnr,
        priority TYPE zstock_alloc_pri-priority,
      END OF ty_rank.
    TYPES ty_rank_tab TYPE STANDARD TABLE OF ty_rank WITH EMPTY KEY.

    DATA mo_demand TYPE REF TO zif_demand_reader.

    METHODS read_ranks
      IMPORTING
        iv_werks       TYPE mard-werks
      RETURNING
        VALUE(rt_rank) TYPE ty_rank_tab.

    METHODS rank_of
      IMPORTING
        it_rank            TYPE ty_rank_tab
        iv_werks           TYPE mard-werks
        iv_kunnr           TYPE vbak-kunnr
      RETURNING
        VALUE(rv_priority) TYPE zif_allocation=>ty_priority.

ENDCLASS.


CLASS zcl_demand_customer_prio IMPLEMENTATION.

  METHOD constructor.
    mo_demand = io_demand.
  ENDMETHOD.

  METHOD zif_demand_reader~read_open_demand.

    rt_demand = mo_demand->read_open_demand(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

    DATA(lt_rank) = read_ranks( iv_werks ).
    IF lt_rank IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT rt_demand ASSIGNING FIELD-SYMBOL(<ls_demand>).

      " demand with no customer is not anybody's key account: a stock
      " transport order is not a customer, which is the same line
      " ZCL_ALLOC_CUSTOMER_CAP draws
      IF <ls_demand>-customer IS INITIAL.
        CONTINUE.
      ENDIF.

      DATA(lv_priority) = rank_of(
        it_rank  = lt_rank
        iv_werks = iv_werks
        iv_kunnr = <ls_demand>-customer ).
      IF lv_priority IS INITIAL.
        CONTINUE.
      ENDIF.

      <ls_demand>-priority = lv_priority.

    ENDLOOP.

  ENDMETHOD.

  METHOD zif_demand_reader~materials_with_demand.

    " which materials a run covers does not depend on who is waiting for them
    rt_matnr = mo_demand->materials_with_demand( iv_werks ).

  ENDMETHOD.

  METHOD read_ranks.

    " the plant's own rows and the ones that apply everywhere, read together
    " and told apart afterwards: two selects for a table this small would be a
    " round trip spent on tidiness
    SELECT werks,
           kunnr,
           priority
      FROM zstock_alloc_pri
      WHERE werks = @iv_werks
         OR werks = @space
      ORDER BY werks, kunnr
      INTO TABLE @rt_rank.
    IF sy-subrc <> 0.
      CLEAR rt_rank.
    ENDIF.

  ENDMETHOD.

  METHOD rank_of.

    " a row for this plant beats one for every plant: the general statement is
    " what a site can be given without asking, the specific one is what a site
    " decided for itself
    READ TABLE it_rank INTO DATA(ls_rank)
      WITH KEY werks = iv_werks
               kunnr = iv_kunnr.
    IF sy-subrc = 0.
      rv_priority = ls_rank-priority.
      RETURN.
    ENDIF.

    READ TABLE it_rank INTO ls_rank
      WITH KEY werks = space
               kunnr = iv_kunnr.
    IF sy-subrc = 0.
      rv_priority = ls_rank-priority.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
