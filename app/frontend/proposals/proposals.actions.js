import axios from 'axios';

export const API_BASE_URL          = '/api';
export const FETCH_PROPOSALS       = 'FETCH_PROPOSALS';
export const FETCH_PROPOSAL        = 'FETCH_PROPOSAL';
export const UPDATE_PROPOSAL       = 'UPDATE_PROPOSAL';
export const APPEND_PROPOSALS_PAGE = 'APPEND_PROPOSALS_PAGE';
export const VOTE_PROPOSAL         = 'VOTE_PROPOSAL';
export const SET_ORDER             = 'SET_ORDER';
export const UPDATE_ANSWER         = 'UPDATE_ANSWER';

export function fetchProposals(options) {
  return {
    type: FETCH_PROPOSALS,
    payload: buildProposalsRequest(options)
  };
}

export function fetchProposal(proposalId) {
  const request = axios.get(`${API_BASE_URL}/proposals/${proposalId}.json`);

  return {
    type: FETCH_PROPOSAL,
    payload: request
  };
}

export function updateProposal(proposalId, proposalParams) {
  const request = axios.patch(`${API_BASE_URL}/proposals/${proposalId}.json`, { proposal: proposalParams });

  return {
    type: UPDATE_PROPOSAL,
    payload: request
  };
}

export function appendProposalsPage(options) {
  return {
    type: APPEND_PROPOSALS_PAGE,
    payload: buildProposalsRequest(options)
  };
}

export function voteProposal(proposalId) {
  const request = axios.post(`${API_BASE_URL}/proposals/${proposalId}/votes.json`);

  return {
    type: VOTE_PROPOSAL,
    payload: request
  };
}

export function setOrder(order) {
  return {
    type: SET_ORDER,
    order
  };
}

export function updateAnswer(proposalId, answer, answerParams) {
  const method  = answer ? 'patch' : 'post';
  const request = axios[method](`${API_BASE_URL}/proposals/${proposalId}/answers.json`, {
    answer: answerParams
  });

  return {
    type: UPDATE_ANSWER,
    payload: request
  };
}

function buildProposalsRequest(options = {}) {
  let filterString = [], 
      filters,
      filter,
      order,
      page,
      seed,
      params;

  filters = options.filters || {};
  page    = options.page || 1;
  order   = options.order;
  seed    = options.seed;

  // TODO: worst name ever
  filter = filters.filter;

  for (let name in filter) {
    if(filter[name].length > 0) {
      filterString.push(`${name}=${filter[name].join(',')}`);
    }
  }

  if (filterString.length > 0) {
    filterString = filterString.join(':');
  }

  params = {
    search: filters.text,
    filter: filterString,
    page: page,
    order: order,
    random_seed: seed
  };

  replaceUrl(params);

  return axios.get(`${API_BASE_URL}/proposals.json`, { params });
}

function replaceUrl(params) {
  if (window.history) {
    let queryParams = [],
        url;

    if (params.search) {
      queryParams.push(`search=${params.search}`);
    }

    if (params.tag && params.tag.length > 0) {
      queryParams.push(`tag=${params.tag}`);
    }

    if (params.filter.length > 0) {
      queryParams.push(`filter=${params.filter}`);
    }

    if (params.order) {
      queryParams.push(`order=${params.order}`);
    }

    if (params.random_seed) {
      queryParams.push(`random_seed=${params.random_seed}`);
    }

    if (queryParams.length > 0) {
      url = `${location.href.replace(/\?.*/, "")}?${queryParams.join('&')}`;
    }

    params.turbolinks = true;

    history.pushState(params, '', url);
  }
}
