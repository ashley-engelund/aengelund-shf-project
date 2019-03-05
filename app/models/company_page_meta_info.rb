#!/usr/bin/ruby


#--------------------------
#
# @class CompanyPageMetaInfo
#
# @desc Responsibility: Given a company, can return page meta info for the company
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-03-04
#
# @file company_page_meta_info.rb
#
#--------------------------


class CompanyPageMetaInfo


  def initialize(company)
    @company = company
  end

  def title
    SiteMetaInfoDefaults.use_default_if_blank(:title, @company.name)
  end


  def description
    SiteMetaInfoDefaults.use_default_if_blank(:description, @company.description)
  end


  def keywords
    SiteMetaInfoDefaults.use_default_if_blank(:keywords,
                                              @company.business_categories.map(&:name)
    .join(', '))


  end


  def og
    {
        title:       title,
        description: description
    }
  end

end # CompanyPageMetaInfo

