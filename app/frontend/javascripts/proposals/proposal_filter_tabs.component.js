import { Component }     from 'react';

import FilterOptionGroup from '../filters/filter_option_group.component';
import FilterOption      from '../filters/filter_option.component';

export default class ProposalFilterTabs extends Component {
  constructor(props) {
    super(props);

    FilterServiceInstance.initState(
      this.props.filter.search_filter,
      this.props.filter.tag_filter,
      this.props.filter.params
    );

    this.state = FilterServiceInstance.state;
  }

  componentDidMount() {
    FilterServiceInstance.subscribe('ProposalFilterTabs', {
      requestUrl: this.props.filterUrl,
      requestDataType: 'script',
      onResultsCallback: (result) => {
        $(document).trigger('loading:hide');
        this.setState(FilterServiceInstance.state);
      }
    });
  }

  componentWillUnmount() {
    FilterServiceInstance.unsubscribe('ProposalFilterTabs');
  }

  render() {
    return (
      <div className="proposal-filter-tabs">
        <FilterOptionGroup 
          renderAs="tabs"
          filterGroupName="source" 
          filterGroupValue={this.state.filters.get('source')}
          isExclusive={true}
          onChangeFilterGroup={(filterGroupName, filterGroupValue) => this.onChangeFilterGroup(filterGroupName, filterGroupValue) }>
          <FilterOption filterName="official" />
          <FilterOption filterName="meetings" filterLabel={I18n.t('components.filter_option.from_meetings')} />
          <FilterOption filterName="citizenship" />
          <FilterOption filterName="organization" />
        </FilterOptionGroup>
      </div>
    )
  }

  onChangeFilterGroup(filterGroupName, filterGroupValue) {
    $(document).trigger('loading:show');
    FilterServiceInstance.cleanState({ notify: false });
    FilterServiceInstance.changeFilterGroup(filterGroupName, filterGroupValue);
    this.setState(FilterServiceInstance.state);
  }
}

