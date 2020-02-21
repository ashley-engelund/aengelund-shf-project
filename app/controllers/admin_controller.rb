class AdminController < AdminOnlyController

  # FIXME - this is really an exporter!
  # FIXME - DRY


  # export shf_appplications
  def export_ansokan_csv

    begin
      @shf_applications = ShfApplication.includes(:user).all

      export_name = "Ansokningar-#{Time.zone.now.strftime('%Y-%m-%d--%H-%M-%S')}.csv"

      send_data(export_shf_apps_str(@shf_applications), filename: export_name, type: "text/plain")

      helpers.flash_message(:notice, t('.success'))

    rescue => e

      helpers.flash_message(:alert, "#{t('.error')} [#{e.message}]")
      redirect_to(request.referer.present? ? :back : root_path)

    end

  end


  def export_payments_csv
    payments = Payment.includes(:user).includes(:company).all
    export_name = "betalningar-#{Time.zone.now.strftime('%Y-%m-%d--%H-%M-%S')}.csv"
    file_contents = items_export_str(payments, Adapters::PaymentToCsvAdapter, export_payments_header_str)

    export_file(file_contents, export_name, success_msg: t('.success'), error_msg: t('.error'))
  end


  def export_payments_covering_year_csv

    year = params[:year].to_i
    # FIXME - check params.  error if year is missing

    payments = Payment.includes(:user).includes(:company).covering_year(year.to_i)
    payments_for_year = payments.map { |payment| PaymentCoveringYear.new(payment: payment, year: year) }

    export_name = "betalningar-for-#{year}--#{Time.zone.now.strftime('%Y-%m-%d--%H-%M-%S')}.csv"
    file_contents = items_export_str(payments_for_year, Adapters::PaymentCoveringYearToCsvAdapter,
                                     export_payments_covering_year_header_str(year))

    export_file(file_contents, export_name, success_msg: t('.success'), error_msg: t('.error'))
  end


  private

  def export_file(file_contents_str, export_filename,
                  success_msg: 'Success!', error_msg: 'Error: something went wrong with the export.')
    begin
      send_data(file_contents_str,
                filename: export_filename, type: "text/plain")

      helpers.flash_message(:notice, success_msg)

    rescue => e
      helpers.flash_message(:alert, error_msg)
      redirect_to(request.referer.present? ? :back : root_path)
    end

  end


  def items_export_str(items = [], csv_adapter_class = nil, header_str = '')
    out_str = header_str
    items.each do |item|
      out_str << csv_adapter_class.new(item).as_target.to_s unless csv_adapter_class.nil?
      out_str << "\n"
    end
    out_str.encode('UTF-8')
  end


  # Create a comma separated string for all applications, each application is 1 row
  # so that the info can be used by SHF for reporting,
  # to import into other systems, and as
  # checklists (e.g. to see who has/has not got a membership packet yet, etc.)
  #
  # @param shf_apps [Array] - a list of ShfApplications; 1 for each row to be exported
  # @return [String] - the Comma Separated Values (CSV) list, with a header and 1
  #    row of information for each application
  #
  def export_shf_apps_str(shf_apps)

    out_str = export_shf_apps_header_str

    shf_apps.each do |shf_app|
      out_str << Adapters::ShfApplicationToCsvAdapter.new(shf_app).as_target.to_s
      out_str << "\n"
    end

    out_str.encode('UTF-8')
  end


  # FIXME - these headers should belong to the Adapters

  # build the CSV export ShfApplications header string from strings in the locale file(s)
  def export_shf_apps_header_str

    header_strs = [t('activerecord.attributes.shf_application.contact_email'),
                   t('activerecord.attributes.user.email'),
                   t('activerecord.attributes.shf_application.first_name'),
                   t('activerecord.attributes.shf_application.last_name'),
                   t('activerecord.attributes.user.membership_number'),
                   t('activerecord.attributes.user.date_member_packet_sent'),
                   t('activerecord.attributes.shf_application.state'),
                   t('admin.export_ansokan_csv.date_state_changed'),
                   t('activerecord.models.business_category.other'),
                   t('activerecord.models.company.one'),
                   t('admin.export_ansokan_csv.member_fee_paid'),
                   t('admin.export_ansokan_csv.member_fee_expires'),
                   t('admin.export_ansokan_csv.branding_fee_paid'),
                   t('admin.export_ansokan_csv.branding_fee_expires'),
                   t('activerecord.attributes.address.street'),
                   t('activerecord.attributes.address.post_code'),
                   t('activerecord.attributes.address.city'),
                   t('activerecord.attributes.address.kommun'),
                   t('activerecord.attributes.address.region'),
                   t('activerecord.attributes.address.country'),
    ]
    create_header_str(header_strs)
  end


  # build the CSV export Payments header string from strings in the locale file(s)
  def export_payments_header_str
    payment_attribs = 'activerecord.attributes.payment'

    header_strs = ['id',
                   t('name'),
                   'E-post',
                   'SEK',
                   'Org.',
                   t('org_nr'),
                   t('payment_type', scope: payment_attribs),
                   t('start_date', scope: payment_attribs),
                   t('expire_date', scope: payment_attribs),
                   t('created', scope: payment_attribs),
                   t('status', scope: payment_attribs),
                   'HIPS id',
                   t('notes', scope: payment_attribs)
    ]
    create_header_str(header_strs)
  end


  def export_payments_covering_year_header_str(year)
    payment_attribs = 'activerecord.attributes.payment'

    header_strs = ['id',
                   t('name'),
                   'E-post',

                   t('payment_type', scope: payment_attribs),
                   'total payment',

                   'Term ' + t('start_date', scope: payment_attribs),
                   'Term ' + t('expire_date', scope: payment_attribs),
                   'total # days paid',

                   'SEK / dag',
                   "# days #{year} paid for",
                   "SEK paid in #{year}",

                   'Pay. date',
                   'Org.',
                   t('org_nr'),
                   t('status', scope: payment_attribs),
                   'HIPS id',
                   t('notes', scope: payment_attribs)
    ]
    create_header_str(header_strs)
  end


  def create_header_str(header_entries)
    out_str = '' # is this stmt needed?

    out_str << header_entries.map { |header_str| "#{header_str.strip}" }.join(',')

    out_str << "\n"
  end
end
