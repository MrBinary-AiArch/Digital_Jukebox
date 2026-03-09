import axios from 'axios';

const api = axios.create({
  baseURL: '/api',
});

export const getUnidentifiedAlbums = async () => {
  const response = await api.get('/unidentified-albums');
  return response.data;
};

export const identifyAlbum = async (folderName: string, query?: string, barcode?: string) => {
  const params: any = {};
  if (query) params.q = query;
  if (barcode) params.barcode = barcode;
  const response = await api.post(`/identify-album/${folderName}`, null, { params });
  return response.data;
};

export const applyTags = async (folderName: string, tagData: any) => {
  const response = await api.post(`/apply-tags/${folderName}`, tagData);
  return response.data;
};
