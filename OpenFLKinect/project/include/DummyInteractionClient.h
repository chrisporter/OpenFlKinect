#ifndef DUMMY_INTERACION_CLIENT_H
#define DUMMY_INTERACION_CLIENT_H

#include "KinectInteraction.h"

namespace openflkinect
{
class DummyInteractionClient : public INuiInteractionClient
{
public:

    STDMETHOD(GetInteractionInfoAtLocation)(DWORD skeletonTrackingId, NUI_HAND_TYPE handType,
        FLOAT x, FLOAT y, NUI_INTERACTION_INFO *pInteractionInfo)
    {
        if(pInteractionInfo)
        {
            pInteractionInfo->IsPressTarget = false;
            pInteractionInfo->PressTargetControlId = 0;
            pInteractionInfo->PressAttractionPointX = 0.f;
            pInteractionInfo->PressAttractionPointY = 0.f;
            pInteractionInfo->IsGripTarget = true;
            return S_OK;
        }
        return E_POINTER;
    }

    STDMETHODIMP_(ULONG) AddRef() { return 2; }
    STDMETHODIMP_(ULONG) Release() { return 1; }
    STDMETHODIMP QueryInterface(REFIID riid, void **ppv) { return S_OK; }

};
}
#endif
